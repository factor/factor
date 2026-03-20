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

fn markDataIfNeeded(gc: *GC, addr: Cell, size: Cell) void {
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

/// Safe push — for root scanning where total push count is hard to bound.
fn markStackPush(gc: *GC, value: Cell) void {
    gc.mark_stack.append(gc.allocator, value) catch @panic("Mark stack overflow");
}

/// Fast push — for drain loop where markStackEnsure was called first.
fn markStackPushFast(gc: *GC, value: Cell) void {
    gc.mark_stack.appendAssumeCapacity(value);
}

/// Ensure the mark stack has room for at least `n` more pushes.
/// Called before scanning an object's slots in the drain loop.
fn markStackEnsure(gc: *GC, n: Cell) void {
    gc.mark_stack.ensureUnusedCapacity(gc.allocator, n) catch @panic("Mark stack overflow");
}

// Mark a value during full GC. Comptime `assume_capacity` selects fast push
// (drain loop, where markStackEnsure was called) vs safe push (root scanning).
// Computes object size and sets full mark range at encounter time (matching
fn fullMarkValueImpl(comptime assume_capacity: bool, ctx: *FullMarkContext, value: Cell) Cell {
    if (layouts.isImmediate(value)) return value;
    const untagged = layouts.UNTAG(value);
    if (untagged < 0x1000) return value;

    if (ctx.tenured.contains(untagged)) {
        if (!ctx.tenured.marks.isMarkedUnchecked(untagged)) {
            const size = free_list.objectSizeFromHeader(untagged);
            if (ctx.tenured.marks.tryMarkStartUnchecked(untagged, size)) {
                if (assume_capacity) markStackPushFast(ctx.gc, untagged) else markStackPush(ctx.gc, untagged);
            }
        }
        return value;
    }

    // Slow path: nursery/aging copy
    const new_value = ctx.destination.copy(value);
    const new_addr = layouts.UNTAG(new_value);
    if (ctx.tenured.contains(new_addr)) {
        const size = free_list.objectSizeFromHeader(new_addr);
        if (ctx.tenured.marks.tryMarkStartUnchecked(new_addr, size)) {
            if (assume_capacity) markStackPushFast(ctx.gc, new_addr) else markStackPush(ctx.gc, new_addr);
        }
    }
    return new_value;
}

// Safe versions (root scanning — no capacity guarantee)
fn fullMarkValue(ctx: *FullMarkContext, value: Cell) Cell {
    return fullMarkValueImpl(false, ctx, value);
}

fn fullMarkSlot(slot: *Cell, ctx_ptr: *anyopaque) void {
    const ctx: *FullMarkContext = @ptrCast(@alignCast(ctx_ptr));
    slot.* = fullMarkValue(ctx, slot.*);
}

// Fast versions (drain loop — markStackEnsure was called)
fn fullMarkValueFast(ctx: *FullMarkContext, value: Cell) Cell {
    return fullMarkValueImpl(true, ctx, value);
}

fn fullMarkSlotInlineFast(slot: *Cell, ctx: *FullMarkContext) void {
    slot.* = fullMarkValueFast(ctx, slot.*);
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

fn fullMarkStackSlots(top: Cell, seg: *const segments.Segment, ctx: *FullMarkContext) void {
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

        // return addresses are resolved by previous block start without
        // requiring an in-block extent check.
        const owner = lookup.ownerForAddressUnsafe(addr) orelse {
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
fn fullMarkSlotInline(slot: *Cell, ctx: *FullMarkContext) void {
    slot.* = fullMarkValue(ctx, slot.*);
}

// Inline helper: mark the code block for a word/quotation entry point.
fn fullMarkEntryPoint(gc: *GC, entry_point: Cell) void {
    if (entry_point != 0) {
        if (gc.vm.code) |code| {
            if (entry_point >= code.code_start and entry_point < code.code_start + code.code_size) {
                const block: *code_blocks.CodeBlock = @ptrFromInt(entry_point - @sizeOf(code_blocks.CodeBlock));
                markCodeBlockIfNeeded(gc, block);
            }
        }
    }
}

/// Fixup for full mark phase: marks/copies slot values and tracks code block entry points.
/// Uses fast mark stack push (assumes capacity was pre-allocated via ensureSlotCapacity).
const FullMarkFixup = struct {
    gc: *GC,
    ctx: *FullMarkContext,

    pub fn visitSlot(self: *@This(), slot: *Cell) void {
        slot.* = fullMarkValueFast(self.ctx, slot.*);
    }

    pub fn ensureSlotCapacity(self: *@This(), n: Cell) void {
        markStackEnsure(self.gc, n);
    }

    pub fn visitEntryPoint(self: *@This(), entry_point: Cell) void {
        fullMarkEntryPoint(self.gc, entry_point);
    }

    pub fn visitCallstackObject(self: *@This(), stack: *layouts.Callstack) void {
        markCallstackObject(self.gc, stack, self.ctx.tenured);
    }
};

// Process a data object from the mark stack using the generic slot visitor.
fn fullProcessDataObject(gc: *GC, addr: Cell, ctx: *FullMarkContext) void {
    var fixup = FullMarkFixup{ .gc = gc, .ctx = ctx };
    _ = slot_visitor.visitDataObjectSlots(FullMarkFixup, &fixup, addr);
}

fn fullProcessCodeBlock(gc: *GC, block: *code_blocks.CodeBlock, ctx: *FullMarkContext) void {
    if (block.isFree()) return;
    const code_heap = gc.vm.code orelse return;

    // Header fields (3 slots + reloc literals)
    markStackEnsure(gc, 3);
    fullMarkSlotInlineFast(@ptrCast(&block.owner), ctx);
    fullMarkSlotInlineFast(@ptrCast(&block.parameters), ctx);
    fullMarkSlotInlineFast(@ptrCast(&block.relocation), ctx);

    const is_uninitialized = code_heap.isBlockUninitialized(block);

    // Embedded literals (copy/update + mark)
    if (!is_uninitialized and block.relocation != layouts.false_object and
        layouts.hasTag(block.relocation, .byte_array))
    {
        const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(block.relocation));
        const reloc_cap = layouts.untagFixnumUnsigned(reloc_ba.capacity);
        if (reloc_cap > 0) {
            const reloc_data = reloc_ba.data();
            const reloc_count = reloc_cap / @sizeOf(code_blocks.RelocationEntry);
            // Each literal can push 1 mark + 1 copy
            markStackEnsure(gc, reloc_count);
            var param_index: Cell = 0;
            var modified = false;
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
                        const new_value = fullMarkValueFast(ctx, value_unsigned);
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
            if (modified) block.flushIcache();
        }
    }

    // Embedded code pointers
    markEmbeddedCodePointers(gc, block, is_uninitialized);
}

pub fn fullDrainMarkStack(gc: *GC, ctx: *FullMarkContext) void {
    while (gc.mark_stack.items.len > 0) {
        const addr = gc.mark_stack.pop().?;
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
    gc.mark_stack.clearRetainingCapacity();

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

fn markStackSlots(top: Cell, seg: *const segments.Segment, gc: *GC, tenured: *data_heap_mod.TenuredSpace) void {
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

        const owner = lookup.ownerForAddressUnsafe(addr) orelse {
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

        const owner = lookup.ownerForAddressUnsafe(addr) orelse {
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

// Mark a single slot value. If it points to a tenured object that
// isn't yet marked, mark it and push to mark stack.
fn markSlot(gc: *GC, slot: *Cell, tenured: *data_heap_mod.TenuredSpace) void {
    const value = slot.*;

    // Skip immediates
    if (layouts.isImmediate(value)) {
        return;
    }

    const untagged = layouts.UNTAG(value);

    if (untagged < 0x1000) return;

    if (!tenured.contains(untagged)) return;

    if (tenured.marks.isMarkedUnchecked(untagged)) return;

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
        markStackPush(gc, addr | 1);
    }
}

// Mark embedded literals in a code block
fn markEmbeddedLiterals(
    gc: *GC,
    block: *code_blocks.CodeBlock,
    tenured: *data_heap_mod.TenuredSpace,
    is_uninitialized: bool,
) void {
    if (gc.vm.code) |code| {
        if (!code.blockHasLiterals(block)) return;
    }
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

/// Fixup for simple mark phase: marks tenured slot values and tracks code blocks.
const SimpleMarkFixup = struct {
    gc: *GC,
    tenured: *data_heap_mod.TenuredSpace,

    pub fn visitSlot(self: *@This(), slot: *Cell) void {
        const value = slot.*;
        if (!layouts.isImmediate(value)) {
            markSlot(self.gc, slot, self.tenured);
        }
    }

    pub fn ensureSlotCapacity(self: *@This(), n: Cell) void {
        markStackEnsure(self.gc, n);
    }

    pub fn visitEntryPoint(self: *@This(), entry_point: Cell) void {
        if (entry_point == 0) return;
        const code = self.gc.vm.code orelse return;
        if (entry_point >= code.code_start and entry_point < code.code_start + code.code_size) {
            const block: *code_blocks.CodeBlock = @ptrFromInt(entry_point - @sizeOf(code_blocks.CodeBlock));
            markCodeBlock(self.gc, block);
        }
    }

    pub fn visitCallstackObject(self: *@This(), stack: *layouts.Callstack) void {
        markCallstackObject(self.gc, stack, self.tenured);
    }
};

// Drain the mark stack - pop objects, visit their slots, which may
// push more objects onto the stack. This implements transitive closure.
// Odd addresses are code blocks (ptr+1), even addresses are data objects.
fn drainMarkStack(gc: *GC) void {
    const tenured = &gc.heap.tenured;
    const code_opt = gc.vm.code;
    const has_uninitialized = if (code_opt) |code| code.uninitialized_blocks.count() != 0 else false;

    var fixup = SimpleMarkFixup{ .gc = gc, .tenured = tenured };

    while (gc.mark_stack.items.len > 0) {
        const addr = gc.mark_stack.pop().?;

        if ((addr & 1) == 1) {
            // Code block
            const block: *code_blocks.CodeBlock = @ptrFromInt(addr - 1);
            if (block.isFree()) continue;

            markSlot(gc, @ptrCast(&block.owner), tenured);
            markSlot(gc, @ptrCast(&block.parameters), tenured);
            markSlot(gc, @ptrCast(&block.relocation), tenured);

            const is_uninitialized = has_uninitialized and code_opt.?.isBlockUninitialized(block);
            markEmbeddedLiterals(gc, block, tenured, is_uninitialized);
            markEmbeddedCodePointers(gc, block, is_uninitialized);
            continue;
        }

        _ = slot_visitor.visitDataObjectSlots(SimpleMarkFixup, &fixup, addr);
    }
}
