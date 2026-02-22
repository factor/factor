// mark.zig - Mark phase for Factor VM garbage collector
// Handles both the full mark phase (mark+copy from nursery/aging to tenured)
// and the simple mark phase (mark-only after collectToTenured).
//
// Extracted from gc.zig to reduce file size.

const std = @import("std");

const code_blocks = @import("code_blocks.zig");
const contexts = @import("contexts.zig");
const data_heap_mod = @import("data_heap.zig");
const free_list = @import("free_list.zig");
const gc_mod = @import("gc.zig");
const layouts = @import("layouts.zig");
const segments = @import("segments.zig");
const slot_visitor = @import("slot_visitor.zig");
const spill_slots = @import("spill_slots.zig");
const vm_mod = @import("vm.zig");
const callstack_lookup = @import("callstack_lookup.zig");

const Cell = layouts.Cell;
const Context = contexts.Context;
const GC = gc_mod.GarbageCollector;

pub const FullMarkContext = struct {
    gc: *GC,
    destination: *slot_visitor.CopyingDestination,
    tenured: *data_heap_mod.TenuredSpace,
};

inline fn markDataIfNeeded(gc: *GC, addr: Cell, size: Cell) void {
    if (gc.heap.tenured.marks.tryMarkStart(addr, size)) {
        markStackPush(gc, addr);
    }
}

fn markCodeBlockIfNeeded(gc: *GC, block: *code_blocks.CodeBlock) void {
    const code = gc.vm.code orelse return;
    const marks = code.marks orelse return;
    if (block.isFree()) return;

    const addr: Cell = @intFromPtr(block);
    const size = block.size();
    if (marks.tryMarkStart(addr, size)) {
        markStackPush(gc, addr | 1);
    }
}

inline fn markStackPush(gc: *GC, value: Cell) void {
    gc.vm.mark_stack.append(value) catch {
        @panic("Mark stack overflow");
    };
}

// Inline fast path: immediate check, tenured range+mark-bit check.
// Slow paths (size computation, copy) stay non-inline to prevent
// code explosion from objectSizeFromHeader's large switch.
inline fn fullMarkValue(ctx: *FullMarkContext, value: Cell) Cell {
    if (layouts.isImmediate(value)) return value;
    const untagged = layouts.UNTAG(value);
    if (untagged < 0x1000) return value;

    // Fast path: 99%+ of pointers land in tenured (simple range check).
    if (ctx.tenured.contains(untagged)) {
        // Check mark bit BEFORE computing object size. Most revisited
        // objects are already marked; skip the expensive size switch.
        if (!ctx.tenured.marks.isMarked(untagged)) {
            fullMarkTenuredNew(ctx, untagged);
        }
        return value;
    }

    return fullMarkValueSlow(ctx, value);
}

// Non-inline: first visit to a tenured object — set start bit + push.
// Size computation deferred to fullProcessDataObject (single type switch).
fn fullMarkTenuredNew(ctx: *FullMarkContext, untagged: Cell) void {
    if (ctx.tenured.marks.tryMarkStartBitOnly(untagged)) {
        markStackPush(ctx.gc, untagged);
    }
}

// Non-inline: nursery/aging copy path (rare during full GC).
fn fullMarkValueSlow(ctx: *FullMarkContext, value: Cell) Cell {
    // Not in tenured — must be in nursery/aging, copy to tenured.
    const new_value = ctx.destination.copy(value);
    const new_addr = layouts.UNTAG(new_value);
    if (ctx.tenured.contains(new_addr)) {
        if (ctx.tenured.marks.tryMarkStartBitOnly(new_addr)) {
            markStackPush(ctx.gc, new_addr);
        }
    }
    return new_value;
}

fn fullMarkSlot(slot: *Cell, ctx_ptr: *anyopaque) void {
    const ctx: *FullMarkContext = @ptrCast(@alignCast(ctx_ptr));
    slot.* = fullMarkValue(ctx, slot.*);
}

pub fn fullMarkAllRoots(gc: *GC, ctx: *FullMarkContext) void {
    // Special objects
    for (&gc.vm.vm_asm.special_objects) |*slot| {
        fullMarkSlot(slot, @ptrCast(ctx));
    }

    // Contexts and stacks
    fullMarkContexts(gc, ctx);

    // Data roots
    for (gc.vm.data_roots.items) |root_ptr| {
        fullMarkSlot(root_ptr, @ptrCast(ctx));
    }

    // Callback owners
    if (gc.vm.callbacks) |callback_heap| {
        const Ctx = struct {
            ctx: *FullMarkContext,
            fn visit(slot: *Cell, c: @This()) void {
                fullMarkSlot(slot, @ptrCast(c.ctx));
            }
        };
        const c = Ctx{ .ctx = ctx };
        callback_heap.iterateOwnersWithCtx(Ctx, Ctx.visit, c);
    }

    // Uninitialized code blocks (literals array roots)
    if (gc.vm.code) |code| {
        var iter = code.uninitialized_blocks.iterator();
        while (iter.next()) |entry| {
            const value = entry.value_ptr.*;
            const new_value = fullMarkValue(ctx, value);
            entry.value_ptr.* = new_value;

            const block_addr = entry.key_ptr.*;
            const block: *code_blocks.CodeBlock = @ptrFromInt(block_addr);
            markCodeBlockIfNeeded(gc, block);
        }
    }
}

fn fullMarkContexts(gc: *GC, ctx: *FullMarkContext) void {
    for (gc.vm.active_contexts.items) |c| {
        fullMarkContext(c, ctx);
    }

    {
        const c = gc.vm.vm_asm.ctx;
        if (!c.isActive()) {
            fullMarkContext(c, ctx);
        }
    }
}

inline fn fullMarkStackSlots(top: Cell, seg: *const segments.Segment, ctx: *FullMarkContext) void {
    var ptr = seg.start;
    while (ptr <= top) : (ptr += @sizeOf(Cell)) {
        const slot: *Cell = @ptrFromInt(ptr);
        fullMarkSlot(slot, @ptrCast(ctx));
    }
}

fn fullMarkContext(c: *Context, ctx: *FullMarkContext) void {
    for (&c.context_objects) |*slot| {
        fullMarkSlot(slot, @ptrCast(ctx));
    }

    fullMarkCallstack(ctx, c);

    if (c.datastack_seg) |seg| {
        fullMarkStackSlots(c.datastack, seg, ctx);
    }

    if (c.retainstack_seg) |seg| {
        fullMarkStackSlots(c.retainstack, seg, ctx);
    }
}

fn fullMarkSpillSlots(
    stack_pointer: [*]Cell,
    gc_info: *const code_blocks.GcInfo,
    callsite: u32,
    ctx: *FullMarkContext,
) void {
    const Visit = struct {
        fn slot(slot_ptr: *Cell, c: *FullMarkContext) void {
            fullMarkSlotInline(slot_ptr, c);
        }
    };
    spill_slots.visit(*FullMarkContext, stack_pointer, gc_info, callsite, ctx, Visit.slot);
}

fn fullMarkCallstack(ctx: *FullMarkContext, c: *Context) void {
    const code_heap = ctx.gc.vm.code orelse return;
    var lookup = callstack_lookup.Lookup.init(code_heap) orelse return;

    var top = c.callstack_top;
    const bottom = c.callstack_bottom;
    if (top == 0 or bottom == 0 or top >= bottom) return;

    const LEAF_FRAME_SIZE: Cell = code_blocks.CodeBlock.LEAF_FRAME_SIZE;

    while (top < bottom) {
        const addr_ptr: *const Cell = @ptrFromInt(top);
        const addr = addr_ptr.*;
        if (addr == 0) break;

        const owner = lookup.ownerForAddress(addr) orelse {
            top += LEAF_FRAME_SIZE;
            continue;
        };

        markCodeBlockIfNeeded(ctx.gc, @constCast(owner));

        const frame_size = callstack_lookup.Lookup.frameSizeFromAddress(owner, addr);

        const cb: *const code_blocks.CodeBlock = @ptrCast(owner);
        if (cb.blockGcInfo()) |gc_info| {
            const return_address_offset: u32 = @intCast(cb.offset(addr));
            if (lookup.callsiteIndex(gc_info, return_address_offset)) |callsite| {
                const stack_pointer: [*]Cell = @ptrFromInt(top);
                fullMarkSpillSlots(stack_pointer, gc_info, callsite, ctx);
            }
        }

        top += frame_size;
    }
}

// Inline helper: mark/copy a single slot value in-place.
// Eliminates the function pointer indirection that visitObjectSlots uses.
inline fn fullMarkSlotInline(slot: *Cell, ctx: *FullMarkContext) void {
    slot.* = fullMarkValue(ctx, slot.*);
}

// Inline helper: mark the code block for a word/quotation entry point.
inline fn fullMarkEntryPoint(gc: *GC, entry_point: Cell) void {
    if (entry_point != 0) {
        if (gc.vm.code) |code| {
            if (entry_point >= code.code_start and entry_point < code.code_start + code.code_size) {
                const block: *code_blocks.CodeBlock = @ptrFromInt(entry_point - @sizeOf(code_blocks.CodeBlock));
                markCodeBlockIfNeeded(gc, block);
            }
        }
    }
}

// Process a data object from the mark stack. Visits all tagged slots
// and marks referenced code blocks. Uses direct per-type inline visiting
// instead of visitObjectSlots callback to eliminate indirect call overhead
// (matches C++ template inlining via visit_slots<Fixup>).
fn fullProcessDataObject(gc: *GC, addr: Cell, ctx: *FullMarkContext) void {
    const obj: *layouts.Object = @ptrFromInt(addr);
    if (obj.isFree()) return;

    const obj_type = obj.getType();

    // Handle callstack: frames reference code blocks but have no tagged data pointers.
    if (obj_type == .callstack) {
        const stack: *layouts.Callstack = @ptrFromInt(addr);
        const len = layouts.untagFixnumUnsigned(stack.length);
        ctx.tenured.marks.setMarked(addr, layouts.alignCell(@sizeOf(layouts.Callstack) + len, layouts.data_alignment));
        markCallstackObject(gc, stack, ctx.tenured);
        return;
    }

    // No-pointer types: compute size, set mark range, done.
    if (layouts.typeHasNoPointers(obj_type)) {
        const size: Cell = switch (obj_type) {
            .bignum => blk: {
                const bn: *layouts.Bignum = @ptrFromInt(addr);
                break :blk layouts.alignCell(@sizeOf(layouts.Bignum) + layouts.untagFixnumUnsigned(bn.capacity) * @sizeOf(Cell), layouts.data_alignment);
            },
            .byte_array => blk: {
                const arr: *layouts.ByteArray = @ptrFromInt(addr);
                break :blk layouts.alignCell(@sizeOf(layouts.ByteArray) + layouts.untagFixnumUnsigned(arr.capacity), layouts.data_alignment);
            },
            .float => comptime layouts.alignCell(@sizeOf(layouts.BoxedFloat), layouts.data_alignment),
            else => layouts.data_alignment,
        };
        ctx.tenured.marks.setMarked(addr, size);
        return;
    }

    const size: Cell = switch (obj_type) {
        .array => blk: {
            const arr: *layouts.Array = @ptrFromInt(addr);
            const capacity = layouts.untagFixnumUnsigned(arr.capacity);
            const data = arr.data();
            for (0..capacity) |i| {
                fullMarkSlotInline(&data[i], ctx);
            }
            break :blk layouts.alignCell(@sizeOf(layouts.Array) + capacity * @sizeOf(Cell), layouts.data_alignment);
        },
        .tuple => blk: {
            const tuple: *layouts.Tuple = @ptrFromInt(addr);
            fullMarkSlotInline(@ptrCast(&tuple.layout), ctx);
            const layout_addr = layouts.followForwardingPointers(tuple.layout);
            const layout: *layouts.TupleLayout = @ptrFromInt(layout_addr);
            const tuple_size = layouts.untagFixnumUnsigned(layout.size);
            const data = tuple.data();
            for (0..tuple_size) |i| {
                fullMarkSlotInline(&data[i], ctx);
            }
            break :blk layouts.alignCell(@sizeOf(layouts.Tuple) + tuple_size * @sizeOf(Cell), layouts.data_alignment);
        },
        .word => blk: {
            const word: *layouts.Word = @ptrFromInt(addr);
            fullMarkSlotInline(@ptrCast(&word.hashcode_field), ctx);
            fullMarkSlotInline(@ptrCast(&word.name), ctx);
            fullMarkSlotInline(@ptrCast(&word.vocabulary), ctx);
            fullMarkSlotInline(@ptrCast(&word.def), ctx);
            fullMarkSlotInline(@ptrCast(&word.props), ctx);
            fullMarkSlotInline(@ptrCast(&word.pic_def), ctx);
            fullMarkSlotInline(@ptrCast(&word.pic_tail_def), ctx);
            fullMarkSlotInline(@ptrCast(&word.subprimitive), ctx);
            fullMarkEntryPoint(gc, word.entry_point);
            break :blk comptime layouts.alignCell(@sizeOf(layouts.Word), layouts.data_alignment);
        },
        .quotation => blk: {
            const quot: *layouts.Quotation = @ptrFromInt(addr);
            fullMarkSlotInline(@ptrCast(&quot.array), ctx);
            fullMarkSlotInline(@ptrCast(&quot.cached_effect), ctx);
            fullMarkSlotInline(@ptrCast(&quot.cache_counter), ctx);
            fullMarkEntryPoint(gc, quot.entry_point);
            break :blk comptime layouts.alignCell(@sizeOf(layouts.Quotation), layouts.data_alignment);
        },
        .wrapper => blk: {
            const wrapper: *layouts.Wrapper = @ptrFromInt(addr);
            fullMarkSlotInline(@ptrCast(&wrapper.object), ctx);
            break :blk comptime layouts.alignCell(@sizeOf(layouts.Wrapper), layouts.data_alignment);
        },
        .string => blk: {
            const str: *layouts.String = @ptrFromInt(addr);
            fullMarkSlotInline(@ptrCast(&str.aux), ctx);
            fullMarkSlotInline(@ptrCast(&str.hashcode_field), ctx);
            break :blk layouts.alignCell(@sizeOf(layouts.String) + layouts.untagFixnumUnsigned(str.length), layouts.data_alignment);
        },
        .alien => blk: {
            const alien: *layouts.Alien = @ptrFromInt(addr);
            fullMarkSlotInline(@ptrCast(&alien.base), ctx);
            fullMarkSlotInline(@ptrCast(&alien.expired), ctx);
            alien.updateAddress();
            break :blk comptime layouts.alignCell(@sizeOf(layouts.Alien), layouts.data_alignment);
        },
        .dll => blk: {
            const dll: *layouts.Dll = @ptrFromInt(addr);
            fullMarkSlotInline(@ptrCast(&dll.path), ctx);
            break :blk comptime layouts.alignCell(@sizeOf(layouts.Dll), layouts.data_alignment);
        },
        else => layouts.data_alignment,
    };
    ctx.tenured.marks.setMarked(addr, size);
}

fn fullProcessCodeBlock(gc: *GC, block: *code_blocks.CodeBlock, ctx: *FullMarkContext) void {
    if (block.isFree()) return;
    const code_heap = gc.vm.code orelse return;

    // Header fields
    fullMarkSlot(@ptrCast(&block.owner), @ptrCast(ctx));
    fullMarkSlot(@ptrCast(&block.parameters), @ptrCast(ctx));
    fullMarkSlot(@ptrCast(&block.relocation), @ptrCast(ctx));

    const is_uninitialized = code_heap.isBlockUninitialized(block);

    // Embedded literals (copy/update + mark)
    if (!is_uninitialized) {
        var modified = false;
        if (code_heap.literalSitesForBlock(block)) |sites| {
            for (sites) |site| {
                var op = code_blocks.InstructionOperand.init(site.rel, block, @as(Cell, site.param_index));
                const value = op.loadValue();
                const value_unsigned: Cell = @bitCast(value);
                if (!layouts.isImmediate(value_unsigned)) {
                    const new_value = fullMarkValue(ctx, value_unsigned);
                    if (new_value != value_unsigned) {
                        op.storeValue(@bitCast(new_value));
                        modified = true;
                    }
                }
            }
        } else if (block.relocation != layouts.false_object and
            layouts.hasTag(block.relocation, .byte_array))
        {
            const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(block.relocation));
            const reloc_cap = layouts.untagFixnumUnsigned(reloc_ba.capacity);
            if (reloc_cap > 0) {
                const reloc_data = reloc_ba.data();
                const reloc_count = reloc_cap / @sizeOf(code_blocks.RelocationEntry);
                var param_index: Cell = 0;
                for (0..reloc_count) |i| {
                    const entry_ptr: *const code_blocks.RelocationEntry =
                        @ptrCast(@alignCast(reloc_data + i * @sizeOf(code_blocks.RelocationEntry)));
                    const entry = entry_ptr.*;
                    const rel_type = entry.getType();
                    if (rel_type == .literal) {
                        var op = code_blocks.InstructionOperand.init(entry, block, param_index);
                        const value = op.loadValue();
                        const value_unsigned: Cell = @bitCast(value);
                        if (!layouts.isImmediate(value_unsigned)) {
                            const new_value = fullMarkValue(ctx, value_unsigned);
                            if (new_value != value_unsigned) {
                                op.storeValue(@bitCast(new_value));
                                modified = true;
                            }
                        }
                    }
                    switch (rel_type) {
                        .vm => param_index += 1,
                        .dlsym => param_index += 2,
                        else => {},
                    }
                }
            }
        }
        if (modified) block.flushIcache();
    }

    // Embedded code pointers
    markEmbeddedCodePointers(gc, block, is_uninitialized);
}

pub fn fullDrainMarkStack(gc: *GC, ctx: *FullMarkContext) void {
    while (gc.vm.mark_stack.len() > 0) {
        const addr = gc.vm.mark_stack.pop() orelse break;
        if ((addr & 1) == 1) {
            const block: *code_blocks.CodeBlock = @ptrFromInt(addr - 1);
            fullProcessCodeBlock(gc, block, ctx);
        } else {
            fullProcessDataObject(gc, addr, ctx);
        }
    }
}

// --- Simple mark phase (mark-only after collectToTenured) ---

pub fn markPhase(gc: *GC) void {
    // Clear mark bits
    gc.heap.tenured.clearMarks();
    if (gc.vm.code) |code| {
        if (code.marks == null) {
            code.ensureMarks(gc.allocator) catch @panic("OOM");
        }
        code.clearMarks();
    }

    // Clear mark stack
    gc.vm.mark_stack.clearRetainingCapacity();

    // Visit all roots - mark reachable tenured objects
    markAllRoots(gc);

    // Drain mark stack - transitively mark all reachable objects
    drainMarkStack(gc);
}

// Visit all roots for marking (full GC version).
// Unlike the copying collector's visitAllRoots which copies objects,
// this marks tenured objects in-place and pushes them to the mark stack.
fn markAllRoots(gc: *GC) void {
    const tenured = &gc.heap.tenured;

    // Visit special objects
    for (&gc.vm.vm_asm.special_objects) |*slot| {
        markSlot(gc, slot, tenured);
    }

    // Visit all contexts
    markContexts(gc, tenured);

    // Visit data roots
    for (gc.vm.data_roots.items) |root_ptr| {
        markSlot(gc, root_ptr, tenured);
    }

    // Visit callback stubs (GC roots)
    if (gc.vm.callbacks) |callback_heap| {
        const Ctx = struct {
            g: *GC,
            ten: *data_heap_mod.TenuredSpace,
            fn visit(slot: *Cell, ctx: @This()) void {
                markSlot(ctx.g, slot, ctx.ten);
            }
        };
        const ctx = Ctx{ .g = gc, .ten = tenured };
        callback_heap.iterateOwnersWithCtx(Ctx, Ctx.visit, ctx);
    }

    if (gc.vm.code) |code| {
        var iter = code.uninitialized_blocks.iterator();
        while (iter.next()) |entry| {
            // Uninitialized block literals are roots.
            markSlot(gc, entry.value_ptr, tenured);

            // Uninitialized code blocks themselves are roots during compilation.
            const block_addr = entry.key_ptr.*;
            const block: *code_blocks.CodeBlock = @ptrFromInt(block_addr);
            markCodeBlock(gc, block);
        }
    }
}

// Visit all contexts for marking
fn markContexts(gc: *GC, tenured: *data_heap_mod.TenuredSpace) void {
    for (gc.vm.active_contexts.items) |ctx| {
        markContext(gc, ctx, tenured);
    }

    {
        const ctx = gc.vm.vm_asm.ctx;
        if (!ctx.isActive()) {
            markContext(gc, ctx, tenured);
        }
    }
}

inline fn markStackSlots(top: Cell, seg: *const segments.Segment, gc: *GC, tenured: *data_heap_mod.TenuredSpace) void {
    var ptr = seg.start;
    while (ptr <= top) : (ptr += @sizeOf(Cell)) {
        const slot: *Cell = @ptrFromInt(ptr);
        markSlot(gc, slot, tenured);
    }
}

// Visit a single context for marking
fn markContext(gc: *GC, ctx: *Context, tenured: *data_heap_mod.TenuredSpace) void {
    // Visit context objects
    for (&ctx.context_objects) |*slot| {
        markSlot(gc, slot, tenured);
    }

    // Visit callstack for GC roots in spill slots
    markCallstack(gc, ctx, tenured);

    // Visit datastack
    if (ctx.datastack_seg) |seg| {
        markStackSlots(ctx.datastack, seg, gc, tenured);
    }

    // Visit retainstack
    if (ctx.retainstack_seg) |seg| {
        markStackSlots(ctx.retainstack, seg, gc, tenured);
    }
}

fn markSpillSlots(
    gc: *GC,
    stack_pointer: [*]Cell,
    gc_info: *const code_blocks.GcInfo,
    callsite: u32,
    tenured: *data_heap_mod.TenuredSpace,
) void {
    const Ctx = struct {
        g: *GC,
        ten: *data_heap_mod.TenuredSpace,
    };
    const Visit = struct {
        fn slot(slot_ptr: *Cell, c: Ctx) void {
            markSlot(c.g, slot_ptr, c.ten);
        }
    };
    spill_slots.visit(Ctx, stack_pointer, gc_info, callsite, Ctx{ .g = gc, .ten = tenured }, Visit.slot);
}

// Walk the callstack and mark GC roots in spill slots (marking version).
// Same logic as visitCallstack but marks instead of copies.
fn markCallstack(gc: *GC, ctx: *Context, tenured: *data_heap_mod.TenuredSpace) void {
    const code_heap = gc.vm.code orelse return;
    var lookup = callstack_lookup.Lookup.init(code_heap) orelse return;

    var top = ctx.callstack_top;
    const bottom = ctx.callstack_bottom;

    if (top == 0 or bottom == 0 or top >= bottom) {
        return;
    }

    const LEAF_FRAME_SIZE: Cell = code_blocks.CodeBlock.LEAF_FRAME_SIZE;

    while (top < bottom) {
        const addr_ptr: *const Cell = @ptrFromInt(top);
        const addr = addr_ptr.*;

        if (addr == 0) break;

        const owner = lookup.ownerForAddress(addr) orelse {
            top += LEAF_FRAME_SIZE;
            continue;
        };

        // Mark owning code block as live
        markCodeBlock(gc, @constCast(owner));

        const frame_size = callstack_lookup.Lookup.frameSizeFromAddress(owner, addr);

        // Visit GC roots in this frame's spill slots
        const cb: *const code_blocks.CodeBlock = @ptrCast(owner);
        if (cb.blockGcInfo()) |gc_info| {
            const return_address_offset: u32 = @intCast(cb.offset(addr));

            if (lookup.callsiteIndex(gc_info, return_address_offset)) |callsite| {
                const stack_pointer: [*]Cell = @ptrFromInt(top);
                markSpillSlots(gc, stack_pointer, gc_info, callsite, tenured);
            }
        }

        top += frame_size;
    }
}

// Mark GC roots and code blocks referenced from a callstack object.
fn markCallstackObject(gc: *GC, stack: *layouts.Callstack, tenured: *data_heap_mod.TenuredSpace) void {
    const code_heap = gc.vm.code orelse return;
    var lookup = callstack_lookup.Lookup.init(code_heap) orelse return;
    const frame_length = layouts.untagFixnumUnsigned(stack.length);
    if (frame_length == 0) return;

    const LEAF_FRAME_SIZE: Cell = code_blocks.CodeBlock.LEAF_FRAME_SIZE;
    var frame_offset: Cell = 0;

    while (frame_offset < frame_length) {
        const frame_top = stack.frameTopAt(frame_offset);
        const addr_ptr: *const Cell = @ptrFromInt(frame_top);
        const addr = addr_ptr.*;
        if (addr == 0) break;

        const owner = lookup.ownerForAddress(addr) orelse {
            frame_offset += LEAF_FRAME_SIZE;
            continue;
        };

        markCodeBlock(gc, @constCast(owner));

        if (owner.blockGcInfo()) |gc_info| {
            const return_address_offset: u32 = @intCast(owner.offset(addr));
            if (lookup.callsiteIndex(gc_info, return_address_offset)) |callsite| {
                const stack_pointer: [*]Cell = @ptrFromInt(frame_top);
                markSpillSlots(gc, stack_pointer, gc_info, callsite, tenured);
            }
        }

        const frame_size = owner.stackFrameSizeForAddress(addr);
        frame_offset += frame_size;
    }
}

// Mark code blocks referenced by untagged entry_point fields in objects.
fn markObjectCodePointers(gc: *GC, addr: Cell, tenured: *data_heap_mod.TenuredSpace) void {
    const code = gc.vm.code orelse return;
    const obj: *layouts.Object = @ptrFromInt(addr);
    switch (obj.getType()) {
        .word => {
            const word: *layouts.Word = @ptrFromInt(addr);
            if (word.entry_point != 0) {
                const ep = word.entry_point;
                if (ep >= code.code_start and ep < code.code_start + code.code_size) {
                    const block_addr = ep - @sizeOf(code_blocks.CodeBlock);
                    const block: *code_blocks.CodeBlock = @ptrFromInt(block_addr);
                    markCodeBlock(gc, block);
                }
            }
        },
        .quotation => {
            const quot: *layouts.Quotation = @ptrFromInt(addr);
            if (quot.entry_point != 0) {
                const ep = quot.entry_point;
                if (ep >= code.code_start and ep < code.code_start + code.code_size) {
                    const block_addr = ep - @sizeOf(code_blocks.CodeBlock);
                    const block: *code_blocks.CodeBlock = @ptrFromInt(block_addr);
                    markCodeBlock(gc, block);
                }
            }
        },
        .callstack => {
            const stack: *layouts.Callstack = @ptrFromInt(addr);
            markCallstackObject(gc, stack, tenured);
        },
        else => {},
    }
}

// Mark a single slot value. If it points to a tenured object that
// isn't yet marked, mark it and push to mark stack.
// Ported from C++ full_collection_copier::fixup_data.
fn markSlot(gc: *GC, slot: *Cell, tenured: *data_heap_mod.TenuredSpace) void {
    const value = slot.*;

    // Skip immediates
    if (layouts.isImmediate(value)) {
        return;
    }

    const untagged = layouts.UNTAG(value);

    if (untagged < 0x1000) return;

    if (!tenured.contains(untagged)) return;

    // Fast path: skip already-marked objects (single bit test vs 13-type switch)
    if (tenured.marks.isMarked(untagged)) return;

    const size = free_list.objectSizeFromHeader(untagged);
    if (tenured.marks.tryMarkStart(untagged, size)) {
        markStackPush(gc, untagged);
    }
}

// Mark a code block as live and push to mark stack if newly marked.
fn markCodeBlock(gc: *GC, block: *code_blocks.CodeBlock) void {
    const code = gc.vm.code orelse return;
    const marks = code.marks orelse return;
    if (block.isFree()) return;

    const addr: Cell = @intFromPtr(block);
    const size = block.size();
    if (marks.tryMarkStart(addr, size)) {
        // Use odd address convention for code blocks (matches C++)
        markStackPush(gc, addr | 1);
    }
}

// Mark embedded literals in a code block
fn markEmbeddedLiterals(
    gc: *GC,
    block: *code_blocks.CodeBlock,
    tenured: *data_heap_mod.TenuredSpace,
    is_uninitialized: bool,
    literal_sites: ?[]const code_blocks.LiteralRelocationSite,
) void {
    if (gc.vm.code) |code| {
        if (!code.blockHasLiterals(block)) return;
    }
    if (is_uninitialized) return;

    if (literal_sites) |sites| {
        for (sites) |site| {
            const op = code_blocks.InstructionOperand.init(site.rel, block, @as(Cell, site.param_index));
            const value = op.loadValue();
            const value_unsigned: Cell = @bitCast(value);

            if (!layouts.isImmediate(value_unsigned)) {
                const untagged = layouts.UNTAG(value_unsigned);
                if (untagged >= 0x1000 and tenured.contains(untagged) and !tenured.marks.isMarked(untagged)) {
                    const size = free_list.objectSizeFromHeader(untagged);
                    if (tenured.marks.tryMarkStart(untagged, size)) {
                        markStackPush(gc, untagged);
                    }
                }
            }
        }
        return;
    }

    if (block.relocation == layouts.false_object) return;
    if (!layouts.hasTag(block.relocation, .byte_array)) return;

    const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(block.relocation));
    const reloc_cap = layouts.untagFixnumUnsigned(reloc_ba.capacity);
    if (reloc_cap == 0) return;

    const reloc_data = reloc_ba.data();
    const reloc_count = reloc_cap / @sizeOf(code_blocks.RelocationEntry);

    var param_index: Cell = 0;
    for (0..reloc_count) |i| {
        const entry_ptr: *const code_blocks.RelocationEntry = @ptrCast(@alignCast(reloc_data + i * @sizeOf(code_blocks.RelocationEntry)));
        const entry = entry_ptr.*;
        const rel_type = entry.getType();

        if (rel_type == .literal) {
            var op = code_blocks.InstructionOperand.init(entry, block, param_index);
            const value = op.loadValue();
            const value_unsigned: Cell = @bitCast(value);

            if (!layouts.isImmediate(value_unsigned)) {
                const untagged = layouts.UNTAG(value_unsigned);
                if (untagged >= 0x1000 and tenured.contains(untagged) and !tenured.marks.isMarked(untagged)) {
                    const size = free_list.objectSizeFromHeader(untagged);
                    if (tenured.marks.tryMarkStart(untagged, size)) {
                        markStackPush(gc, untagged);
                    }
                }
            }
        }
        switch (rel_type) {
            .vm => param_index += 1,
            .dlsym => param_index += 2,
            else => {},
        }
    }
}

// Mark code block references embedded in instruction operands
fn markEmbeddedCodePointers(gc: *GC, block: *code_blocks.CodeBlock, is_uninitialized: bool) void {
    const code = gc.vm.code orelse return;
    if (!code.blockHasCodePointers(block)) return;
    if (is_uninitialized) return;

    if (block.relocation == layouts.false_object) return;
    if (!layouts.hasTag(block.relocation, .byte_array)) return;

    const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(block.relocation));
    const reloc_cap = layouts.untagFixnumUnsigned(reloc_ba.capacity);
    if (reloc_cap == 0) return;

    const reloc_data = reloc_ba.data();
    const reloc_count = reloc_cap / @sizeOf(code_blocks.RelocationEntry);

    var param_index: Cell = 0;
    for (0..reloc_count) |i| {
        const entry_ptr: *const code_blocks.RelocationEntry = @ptrCast(@alignCast(reloc_data + i * @sizeOf(code_blocks.RelocationEntry)));
        const entry = entry_ptr.*;
        const rel_type = entry.getType();

        switch (rel_type) {
            .entry_point, .entry_point_pic, .entry_point_pic_tail => {
                const op = code_blocks.InstructionOperand.init(entry, block, param_index);
                const value = op.loadValue();
                const value_unsigned: Cell = @bitCast(value);
                if (value_unsigned >= 0x1000 and value_unsigned >= @sizeOf(code_blocks.CodeBlock)) {
                    const target_addr = value_unsigned - @sizeOf(code_blocks.CodeBlock);
                    if (target_addr >= code.code_start and target_addr < code.code_start + code.code_size) {
                        const target_block: *code_blocks.CodeBlock = @ptrFromInt(target_addr);
                        markCodeBlock(gc, target_block);
                    }
                }
            },
            else => {},
        }

        switch (rel_type) {
            .vm => param_index += 1,
            .dlsym => param_index += 2,
            else => {},
        }
    }
}

// Drain the mark stack - pop objects, visit their slots, which may
// push more objects onto the stack. This implements transitive closure.
// Ported from C++ visit_mark_stack.
// We use the same convention: odd addresses are code blocks (ptr+1),
// even addresses are data objects.
fn drainMarkStack(gc: *GC) void {
    const tenured = &gc.heap.tenured;
    const code_opt = gc.vm.code;
    const has_uninitialized = if (code_opt) |code| code.uninitialized_blocks.count() != 0 else false;

    while (gc.vm.mark_stack.len() > 0) {
        const addr = gc.vm.mark_stack.pop() orelse break;

        if ((addr & 1) == 1) {
            // Code block
            const block: *code_blocks.CodeBlock = @ptrFromInt(addr - 1);
            if (block.isFree()) continue;

            // Mark data references in the block header
            markSlot(gc, @ptrCast(&block.owner), tenured);
            markSlot(gc, @ptrCast(&block.parameters), tenured);
            markSlot(gc, @ptrCast(&block.relocation), tenured);

            const is_uninitialized = has_uninitialized and code_opt.?.isBlockUninitialized(block);
            const literal_sites = code_opt.?.literalSitesForBlock(block);

            // Mark embedded literals and code pointers
            markEmbeddedLiterals(gc, block, tenured, is_uninitialized, literal_sites);
            markEmbeddedCodePointers(gc, block, is_uninitialized);
            continue;
        }

        // Data object: visit slots and code pointers
        const obj: *layouts.Object = @ptrFromInt(addr);
        if (obj.isFree()) continue;

        const VisitCtx = struct {
            g: *GC,
            ten: *data_heap_mod.TenuredSpace,

            fn visit(slot: *Cell, ctx_ptr: *anyopaque) void {
                const ctx: *@This() = @ptrCast(@alignCast(ctx_ptr));
                const value = slot.*;
                if (!layouts.isImmediate(value)) {
                    markSlot(ctx.g, slot, ctx.ten);
                }
            }
        };

        var visit_ctx = VisitCtx{ .g = gc, .ten = tenured };
        slot_visitor.visitObjectSlots(addr, VisitCtx.visit, @ptrCast(&visit_ctx));

        // Mark code blocks referenced by untagged entry points
        markObjectCodePointers(gc, addr, tenured);

        // Update alien address if needed
        if (obj.getType() == .alien) {
            const alien: *layouts.Alien = @ptrFromInt(addr);
            alien.updateAddress();
        }
    }
}
