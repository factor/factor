// compact.zig - Compaction phase for Factor VM garbage collector
// Handles mark-compact GC: moving marked objects, fixing up pointers,
// updating callstacks, code blocks, and instruction operands.
//
// Extracted from gc.zig to reduce file size.

const std = @import("std");
const builtin = @import("builtin");

const c_api = @import("c_api.zig");
const code_blocks = @import("code_blocks.zig");
const contexts = @import("contexts.zig");
const data_heap_mod = @import("data_heap.zig");
const free_list_mod = @import("free_list.zig");
const gc_mod = @import("gc.zig");
const icache = @import("icache.zig");
const segments = @import("segments.zig");
const slot_visitor = @import("slot_visitor.zig");
const sweep_mod = @import("sweep.zig");
const layouts = @import("layouts.zig");
const mark_bits = @import("mark_bits.zig");
const spill_slots = @import("spill_slots.zig");
const trampolines = @import("trampolines.zig");
const vm_mod = @import("vm.zig");

const Cell = layouts.Cell;
const Context = contexts.Context;
const GC = gc_mod.GarbageCollector;

pub const CompactionFixup = struct {
    data_marks: *mark_bits.MarkBits,
    code_marks: ?*mark_bits.MarkBits,
    data_finger: *Cell,
    code_finger: *Cell,

    fn fixupData(self: *CompactionFixup, addr: Cell) Cell {
        return self.data_marks.forwardBlock(addr);
    }

    fn fixupCode(self: *CompactionFixup, addr: Cell) Cell {
        if (self.code_marks) |marks| {
            return marks.forwardBlock(addr);
        }
        return addr;
    }

    fn translateData(self: *CompactionFixup, addr: Cell) Cell {
        if (addr < self.data_finger.*) {
            return self.fixupData(addr);
        }
        return addr;
    }

    fn translateCode(self: *CompactionFixup, addr: Cell) Cell {
        if (self.code_marks == null) return addr;
        if (addr < self.code_finger.*) {
            return self.fixupCode(addr);
        }
        return addr;
    }
};

fn memmoveBytes(dest: Cell, src: Cell, size: Cell) void {
    if (dest == src or size == 0) return;
    const n: usize = @intCast(size);
    const dst: [*]u8 = @ptrFromInt(dest);
    const src_ptr: [*]const u8 = @ptrFromInt(src);
    @memmove(dst[0..n], src_ptr[0..n]);
}

fn fixupSlotValue(fixup: *CompactionFixup, value: Cell) Cell {
    if (layouts.isImmediate(value)) return value;
    const fixed = fixup.fixupData(layouts.UNTAG(value));
    return layouts.RETAG(fixed, layouts.TAG(value));
}

fn fixupSlot(fixup: *CompactionFixup, slot: *Cell) void {
    slot.* = fixupSlotValue(fixup, slot.*);
}

fn objectSizeForCompaction(addr: Cell, fixup: *CompactionFixup) Cell {
    const obj: *layouts.Object = @ptrFromInt(addr);

    if (obj.isFree()) {
        return obj.header & ~@as(Cell, 7);
    }

    return switch (obj.getType()) {
        .array => blk: {
            const arr: *layouts.Array = @ptrFromInt(addr);
            std.debug.assert(layouts.hasTag(arr.capacity, .fixnum));
            const capacity = layouts.untagFixnumUnsigned(arr.capacity);
            break :blk layouts.alignCell(@sizeOf(layouts.Array) + capacity * @sizeOf(Cell), layouts.data_alignment);
        },
        .byte_array => blk: {
            const arr: *layouts.ByteArray = @ptrFromInt(addr);
            std.debug.assert(layouts.hasTag(arr.capacity, .fixnum));
            const capacity = layouts.untagFixnumUnsigned(arr.capacity);
            break :blk layouts.alignCell(@sizeOf(layouts.ByteArray) + capacity, layouts.data_alignment);
        },
        .string => blk: {
            const str: *layouts.String = @ptrFromInt(addr);
            std.debug.assert(layouts.hasTag(str.length, .fixnum));
            const len = layouts.untagFixnumUnsigned(str.length);
            break :blk layouts.alignCell(@sizeOf(layouts.String) + len, layouts.data_alignment);
        },
        .bignum => blk: {
            const bn: *layouts.Bignum = @ptrFromInt(addr);
            std.debug.assert(layouts.hasTag(bn.capacity, .fixnum));
            const capacity = layouts.untagFixnumUnsigned(bn.capacity);
            break :blk layouts.alignCell(@sizeOf(layouts.Bignum) + capacity * @sizeOf(Cell), layouts.data_alignment);
        },
        .tuple => blk: {
            const tuple: *layouts.Tuple = @ptrFromInt(addr);
            const layout_addr = fixup.translateData(layouts.UNTAG(tuple.layout));
            const layout: *layouts.TupleLayout = @ptrFromInt(layout_addr);
            const slots = layouts.untagFixnumUnsigned(layout.size);
            break :blk layouts.alignCell(@sizeOf(layouts.Tuple) + slots * @sizeOf(Cell), layouts.data_alignment);
        },
        .quotation => layouts.alignCell(@sizeOf(layouts.Quotation), layouts.data_alignment),
        .word => layouts.alignCell(@sizeOf(layouts.Word), layouts.data_alignment),
        .wrapper => layouts.alignCell(@sizeOf(layouts.Wrapper), layouts.data_alignment),
        .float => layouts.alignCell(@sizeOf(layouts.BoxedFloat), layouts.data_alignment),
        .alien => layouts.alignCell(@sizeOf(layouts.Alien), layouts.data_alignment),
        .dll => layouts.alignCell(@sizeOf(layouts.Dll), layouts.data_alignment),
        .callstack => blk: {
            const cs: *layouts.Callstack = @ptrFromInt(addr);
            std.debug.assert(layouts.hasTag(cs.length, .fixnum));
            const len = layouts.untagFixnumUnsigned(cs.length);
            break :blk layouts.alignCell(@sizeOf(layouts.Callstack) + len, layouts.data_alignment);
        },
        .fixnum, .f => layouts.data_alignment,
    };
}

fn requireParameters(block: *code_blocks.CodeBlock) *const layouts.Array {
    std.debug.assert(block.parameters != layouts.false_object);
    std.debug.assert(layouts.hasTag(block.parameters, .array));
    return @ptrFromInt(layouts.UNTAG(block.parameters));
}

fn requireParameter(block: *code_blocks.CodeBlock, param_index: Cell) Cell {
    const params = requireParameters(block);
    std.debug.assert(param_index < layouts.untagFixnumUnsigned(params.capacity));
    return params.data()[param_index];
}

fn resetFreeListForCompaction(free_list: *free_list_mod.FreeListAllocator, free_start: Cell, heap_end: Cell) void {
    free_list.reset();

    if (free_start >= heap_end) return;
    const free_size = heap_end - free_start;
    if (free_size >= free_list_mod.min_block_size) {
        free_list.addFreeBlock(free_start, free_size);
    }
}

// --- Functions requiring GC pointer ---

fn fixupCallstackSlots(gc: *GC, ctx: *Context, fixup: *CompactionFixup) void {
    const code_heap = gc.vm.code orelse return;
    const blocks = code_heap.all_blocks_sorted.items;
    if (blocks.len == 0) return;

    var top = ctx.callstack_top;
    const bottom = ctx.callstack_bottom;
    if (top == 0 or bottom == 0 or top >= bottom) return;

    const LEAF_FRAME_SIZE: Cell = code_blocks.CodeBlock.LEAF_FRAME_SIZE;

    while (top < bottom) {
        const addr_ptr: *const Cell = @ptrFromInt(top);
        const addr = addr_ptr.*;
        if (addr == 0) break;

        // Binary search all_blocks_sorted (old addresses)
        const ub = std.sort.upperBound(Cell, blocks, addr, layouts.orderCell);
        if (ub == 0) {
            top += LEAF_FRAME_SIZE;
            continue;
        }
        const old_block_addr = blocks[ub - 1];

        // Get new block address via forwarding map; read from NEW address
        const new_block_addr = fixup.translateCode(old_block_addr);
        const compiled: *const code_blocks.CodeBlock = @ptrFromInt(new_block_addr);

        // Compute offset using old entry point (arithmetic only)
        const old_entry_point = old_block_addr + @sizeOf(code_blocks.CodeBlock);
        const delta = if (addr > old_entry_point) addr - old_entry_point else 0;
        const natural_frame_size = compiled.stackFrameSize();
        var frame_size: Cell = LEAF_FRAME_SIZE;
        if (natural_frame_size > 0 and delta > 0) {
            frame_size = natural_frame_size;
        }

        if (compiled.blockGcInfo()) |gc_info| {
            const return_address_offset: u32 = @intCast(delta);
            if (gc_info.returnAddressIndex(return_address_offset)) |callsite| {
                const stack_pointer: [*]Cell = @ptrFromInt(top);
                const Visit = struct {
                    fn slot(slot_ptr: *Cell, fx: *CompactionFixup) void {
                        fixupSlot(fx, slot_ptr);
                    }
                };
                spill_slots.visit(*CompactionFixup, stack_pointer, gc_info, callsite, fixup, Visit.slot);
            }
        }

        top += frame_size;
    }
}

fn fixupCallstackObjectSlots(gc: *GC, stack: *layouts.Callstack, fixup: *CompactionFixup) void {
    const code_heap = gc.vm.code orelse return;
    const blocks = code_heap.all_blocks_sorted.items;
    if (blocks.len == 0) return;
    const frame_length = layouts.untagFixnumUnsigned(stack.length);
    if (frame_length == 0) return;

    const LEAF_FRAME_SIZE: Cell = code_blocks.CodeBlock.LEAF_FRAME_SIZE;
    var frame_offset: Cell = 0;

    while (frame_offset < frame_length) {
        const frame_top = stack.frameTopAt(frame_offset);
        const addr_ptr: *const Cell = @ptrFromInt(frame_top);
        const addr = addr_ptr.*;
        if (addr == 0) break;

        const ub = std.sort.upperBound(Cell, blocks, addr, layouts.orderCell);
        if (ub == 0) {
            frame_offset += LEAF_FRAME_SIZE;
            continue;
        }
        const old_block_addr = blocks[ub - 1];

        const old_block: *const code_blocks.CodeBlock = @ptrFromInt(old_block_addr);

        // Get compiled block (may be at new address if code forwarding is active)
        const compiled_addr = fixup.translateCode(old_block_addr);
        const compiled: *const code_blocks.CodeBlock = @ptrFromInt(compiled_addr);

        if (compiled.blockGcInfo()) |gc_info| {
            const old_entry_point = old_block.entryPoint();
            const return_address_offset: u32 = @intCast(if (addr >= old_entry_point) addr - old_entry_point else 0);
            if (gc_info.returnAddressIndex(return_address_offset)) |callsite| {
                const stack_pointer: [*]Cell = @ptrFromInt(frame_top);
                const Visit = struct {
                    fn slot(slot_ptr: *Cell, fx: *CompactionFixup) void {
                        fixupSlot(fx, slot_ptr);
                    }
                };
                spill_slots.visit(*CompactionFixup, stack_pointer, gc_info, callsite, fixup, Visit.slot);
            }
        }

        const old_entry_point2 = old_block.entryPoint();
        const delta = if (addr > old_entry_point2) addr - old_entry_point2 else 0;
        const natural_frame_size = compiled.stackFrameSize();
        var frame_size: Cell = LEAF_FRAME_SIZE;
        if (natural_frame_size > 0 and delta > 0) {
            frame_size = natural_frame_size;
        }
        frame_offset += frame_size;
    }
}

fn fixupCallstackReturnAddresses(gc: *GC, ctx: *Context, fixup: *CompactionFixup) void {
    const code_heap = gc.vm.code orelse return;
    const blocks = code_heap.all_blocks_sorted.items;
    if (blocks.len == 0) return;

    var top = ctx.callstack_top;
    const bottom = ctx.callstack_bottom;
    if (top == 0 or bottom == 0 or top >= bottom) return;

    const LEAF_FRAME_SIZE: Cell = code_blocks.CodeBlock.LEAF_FRAME_SIZE;

    while (top < bottom) {
        const addr_ptr: *Cell = @ptrFromInt(top);
        const addr = addr_ptr.*;
        if (addr == 0) break;

        // Binary search all_blocks_sorted (old addresses) to find the owner
        const ub = std.sort.upperBound(Cell, blocks, addr, layouts.orderCell);
        if (ub == 0) {
            top += LEAF_FRAME_SIZE;
            continue;
        }
        const old_block_addr = blocks[ub - 1];

        const new_block_addr = fixup.translateCode(old_block_addr);
        const new_block: *const code_blocks.CodeBlock = @ptrFromInt(new_block_addr);

        const old_entry_point = old_block_addr + @sizeOf(code_blocks.CodeBlock);
        const offset = if (addr > old_entry_point) addr - old_entry_point else 0;

        const natural_frame_size = new_block.stackFrameSize();
        const delta = if (addr > old_entry_point) addr - old_entry_point else 0;
        var frame_size: Cell = LEAF_FRAME_SIZE;
        if (natural_frame_size > 0 and delta > 0) {
            frame_size = natural_frame_size;
        }

        // Update return address to point into the new block
        const new_addr = new_block.entryPoint() + offset;

        addr_ptr.* = new_addr;

        top += frame_size;
    }
}

fn fixupCallstackObjectReturnAddresses(gc: *GC, stack: *layouts.Callstack, fixup: *CompactionFixup) void {
    const code_heap = gc.vm.code orelse return;
    const blocks = code_heap.all_blocks_sorted.items;
    if (blocks.len == 0) return;
    const frame_length = layouts.untagFixnumUnsigned(stack.length);
    if (frame_length == 0) return;

    const LEAF_FRAME_SIZE: Cell = code_blocks.CodeBlock.LEAF_FRAME_SIZE;
    var frame_offset: Cell = 0;

    while (frame_offset < frame_length) {
        const frame_top = stack.frameTopAt(frame_offset);
        const addr_ptr: *Cell = @ptrFromInt(frame_top);
        const addr = addr_ptr.*;
        if (addr == 0) break;

        const ub = std.sort.upperBound(Cell, blocks, addr, layouts.orderCell);
        if (ub == 0) {
            frame_offset += LEAF_FRAME_SIZE;
            continue;
        }
        const old_block_addr = blocks[ub - 1];

        const new_block_addr = fixup.fixupCode(old_block_addr);
        const old_block: *const code_blocks.CodeBlock = @ptrFromInt(old_block_addr);
        const old_entry_point = old_block.entryPoint();
        const offset = if (addr >= old_entry_point) addr - old_entry_point else 0;
        const new_entry_point = new_block_addr + @sizeOf(code_blocks.CodeBlock);
        addr_ptr.* = new_entry_point + offset;

        const delta = offset;
        const natural_frame_size = old_block.stackFrameSize();
        var frame_size: Cell = LEAF_FRAME_SIZE;
        if (natural_frame_size > 0 and delta > 0) {
            frame_size = natural_frame_size;
        }
        frame_offset += frame_size;
    }
}

/// Fixup for compaction: updates data pointers through the forwarding map.
const CompactionSlotFixup = struct {
    gc: *GC,
    fixup: *CompactionFixup,

    pub fn visitSlot(self: *@This(), slot: *Cell) void {
        fixupSlot(self.fixup, slot);
    }

    pub fn resolveTupleLayout(self: *@This(), layout: Cell) Cell {
        return self.fixup.translateData(layouts.UNTAG(layout));
    }

    pub fn visitCallstackObject(self: *@This(), stack: *layouts.Callstack) void {
        fixupCallstackObjectSlots(self.gc, stack, self.fixup);
    }
};

fn fixupObjectSlots(gc: *GC, addr: Cell, fixup: *CompactionFixup) void {
    var slot_fixup = CompactionSlotFixup{ .gc = gc, .fixup = fixup };
    _ = slot_visitor.visitDataObjectSlots(CompactionSlotFixup, &slot_fixup, addr);
}

fn fixupObjectCodePointers(gc: *GC, addr: Cell, fixup: *CompactionFixup) void {
    const obj: *layouts.Object = @ptrFromInt(addr);
    switch (obj.getType()) {
        .word => {
            const word: *layouts.Word = @ptrFromInt(addr);
            if (word.entry_point != 0) {
                // entry_point = code_block_addr + sizeof(CodeBlock)
                // Forward the code_block address, then recompute entry_point
                const code_block_addr = word.entry_point - @sizeOf(code_blocks.CodeBlock);
                const new_code_addr = fixup.fixupCode(code_block_addr);
                word.entry_point = new_code_addr + @sizeOf(code_blocks.CodeBlock);
            }
        },
        .quotation => {
            const quot: *layouts.Quotation = @ptrFromInt(addr);
            if (quot.entry_point != 0) {
                const code_block_addr = quot.entry_point - @sizeOf(code_blocks.CodeBlock);
                const new_code_addr = fixup.fixupCode(code_block_addr);
                quot.entry_point = new_code_addr + @sizeOf(code_blocks.CodeBlock);
            }
        },
        .callstack => {
            const stack: *layouts.Callstack = @ptrFromInt(addr);
            fixupCallstackObjectReturnAddresses(gc, stack, fixup);
        },
        else => {},
    }
}

fn fixupStackSlots(top: Cell, seg: *const segments.Segment, fixup: *CompactionFixup) void {
    var ptr = seg.start;
    while (ptr <= top) : (ptr += @sizeOf(Cell)) {
        const slot: *Cell = @ptrFromInt(ptr);
        fixupSlot(fixup, slot);
    }
}

fn fixupContextRoots(gc: *GC, ctx: *Context, fixup: *CompactionFixup) void {
    for (&ctx.context_objects) |*slot| {
        fixupSlot(fixup, slot);
    }
    fixupCallstackSlots(gc, ctx, fixup);

    if (ctx.datastack_seg) |seg| {
        fixupStackSlots(ctx.datastack, seg, fixup);
    }
    if (ctx.retainstack_seg) |seg| {
        fixupStackSlots(ctx.retainstack, seg, fixup);
    }
}

fn computeExternalRelocationValue(gc: *GC, block: *code_blocks.CodeBlock, rel_type: code_blocks.RelocationType, param_index: Cell) Cell {
    const vm_ptr = @intFromPtr(&gc.vm.vm_asm);
    const cards_offset = gc.vm.vm_asm.cards_offset;
    const decks_offset = gc.vm.vm_asm.decks_offset;
    const megamorphic_hits = @intFromPtr(&gc.vm.dispatch_stats.megamorphic_cache_hits);
    const inline_cache_miss = @intFromPtr(&c_api.inline_cache_miss);
    const safepoint_page = if (gc.vm.code) |code| code.safepoint_page else unreachable;

    return switch (rel_type) {
        .this => block.entryPoint(),
        .dlsym => blk: {
            const params = requireParameters(block);
            std.debug.assert(param_index + 1 < layouts.untagFixnumUnsigned(params.capacity));
            break :blk code_blocks.computeDlsymAddress(params, param_index);
        },
        .vm => blk: {
            const offset_value = requireParameter(block, param_index);
            std.debug.assert(layouts.hasTag(offset_value, .fixnum));
            const base: isize = @bitCast(vm_ptr);
            break :blk @bitCast(base + layouts.untagFixnum(offset_value));
        },
        .cards_offset => cards_offset,
        .decks_offset => decks_offset,
        .megamorphic_cache_hits => megamorphic_hits,
        .inline_cache_miss => inline_cache_miss,
        .safepoint => safepoint_page,
        .trampoline => if (builtin.cpu.arch == .aarch64) @intFromPtr(&trampolines.trampoline) else unreachable,
        .trampoline2 => if (builtin.cpu.arch == .aarch64) @intFromPtr(&trampolines.trampoline2) else unreachable,
        .entry_point,
        .entry_point_pic,
        .entry_point_pic_tail,
        .here,
        .literal,
        .untagged,
        => unreachable,
    };
}

fn updateInstructionOperandsForCompaction(gc: *GC, block: *code_blocks.CodeBlock, old_entry_point: Cell, fixup: *CompactionFixup) bool {
    if (block.relocation == layouts.false_object) return false;
    if (!layouts.hasTag(block.relocation, .byte_array)) return false;

    const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(block.relocation));
    const reloc_cap = layouts.untagFixnumUnsigned(reloc_ba.capacity);
    if (reloc_cap == 0) return false;

    const reloc_data = reloc_ba.data();
    const reloc_count = reloc_cap / @sizeOf(code_blocks.RelocationEntry);

    var param_index: Cell = 0;

    for (0..reloc_count) |i| {
        const entry_ptr: *const code_blocks.RelocationEntry = @ptrCast(@alignCast(reloc_data + i * @sizeOf(code_blocks.RelocationEntry)));

        // Validate class - assert on entries with reserved/invalid class values
        const raw_class = @as(u4, @truncate((entry_ptr.value & 0x0F000000) >> 24));
        const valid_class = switch (raw_class) {
            0, 1, 2, 3, 4, 5, 6, 10, 11 => true,
            else => false,
        };
        std.debug.assert(valid_class);

        const rel_type = entry_ptr.getType();
        var op = code_blocks.InstructionOperand.init(entry_ptr.*, block, 0);

        const old_offset = old_entry_point + @as(Cell, entry_ptr.getOffset());
        const old_value_i64 = op.loadValueRelative(old_offset);
        const old_value: Cell = @bitCast(old_value_i64);

        const new_value: Cell = switch (rel_type) {
            .literal => fixupSlotValue(fixup, old_value),
            .entry_point, .entry_point_pic, .entry_point_pic_tail, .here => blk: {
                const tag = layouts.TAG(old_value);
                const code_addr = layouts.UNTAG(old_value);
                const fixed_addr = fixup.fixupCode(code_addr);
                break :blk layouts.RETAG(fixed_addr, tag);
            },
            .this => block.entryPoint(),
            .untagged => old_value,
            else => computeExternalRelocationValue(gc, block, rel_type, param_index),
        };

        // Always store: even if the absolute target didn't change, relative
        // encodings must be re-written because the instruction moved.
        op.storeValue(@bitCast(new_value));

        param_index += entry_ptr.numberOfParameters();
    }

    return true;
}

fn updateUninitializedBlocksForCompaction(gc: *GC, fixup: *CompactionFixup) void {
    const code = gc.vm.code orelse return;
    const alloc = gc.allocator;

    if (code.uninitialized_blocks.count() == 0) return;

    var new_map = code.uninitialized_blocks_scratch;
    new_map.clearRetainingCapacity();
    new_map.ensureTotalCapacity(alloc, code.uninitialized_blocks.count()) catch @panic("OOM");

    var iter = code.uninitialized_blocks.iterator();
    while (iter.next()) |entry| {
        const old_block = entry.key_ptr.*;
        const old_value = entry.value_ptr.*;
        const new_block = fixup.fixupCode(old_block);
        const new_value = fixupSlotValue(fixup, old_value);
        new_map.putAssumeCapacity(new_block, new_value);
    }

    code.uninitialized_blocks_scratch = code.uninitialized_blocks;
    code.uninitialized_blocks = new_map;
}

fn updateCodeRootsForCompaction(gc: *GC, marks: *mark_bits.MarkBits) void {
    const mask: Cell = ~@as(Cell, layouts.data_alignment) + 1;
    for (gc.vm.code_roots.items) |root| {
        if (!root.valid) continue;
        const block = root.value & mask;
        const offset = root.value - block;
        if (marks.isMarked(block)) {
            const new_block = marks.forwardBlock(block);
            root.value = new_block + offset;
        } else {
            root.valid = false;
        }
    }
}

// Main compaction entry point
pub fn compactPhase(gc: *GC, compact_code_heap: bool) void {
    const tenured = &gc.heap.tenured;
    tenured.marks.computeForwarding();

    var code_marks: ?*mark_bits.MarkBits = null;
    var code_start: Cell = 0;
    var code_end: Cell = 0;

    if (compact_code_heap) {
        if (gc.vm.code) |code| {
            code_start = code.code_start;
            code_end = code.code_start + code.code_size;
            if (code.marks) |marks| {
                marks.computeForwarding();
                code_marks = marks;
            }
        }
    }

    var data_finger: Cell = tenured.start;
    var code_finger: Cell = code_start;
    var fixup = CompactionFixup{
        .data_marks = &tenured.marks,
        .code_marks = code_marks,
        .data_finger = &data_finger,
        .code_finger = &code_finger,
    };

    // Flush any pending code block addresses into the sorted list.
    // fixupCallstackSlots / fixupCallstackReturnAddresses binary-search
    // all_blocks_sorted directly (not codeBlockForAddress which also
    // checks pending_blocks).  Without this flush, recently-compiled
    // blocks would be missed, causing wrong block lookups and corrupt
    // return addresses.
    if (gc.vm.code) |code| {
        code.flushPending();
    }

    // Update uninitialized block map before moving code blocks
    if (compact_code_heap) {
        updateUninitializedBlocksForCompaction(gc, &fixup);
    }

    // Clear object start map; rebuild while compacting
    tenured.object_start.clear();

    // Compact tenured space
    var data_dest: Cell = tenured.start;
    var scan: Cell = tenured.start;
    while (scan < tenured.end) {
        const is_marked = tenured.marks.isMarked(scan);
        const size = if (is_marked)
            objectSizeForCompaction(scan, &fixup)
        else
            tenured.marks.unmarkedBlockSize(scan);

        if (size == 0) break;

        if (is_marked) {
            data_finger = scan + size;

            if (data_dest != scan) {
                memmoveBytes(data_dest, scan, size);
            }

            fixupObjectSlots(gc, data_dest, &fixup);
            fixupObjectCodePointers(gc, data_dest, &fixup);

            tenured.object_start.recordObjectStart(data_dest);
            data_dest += size;
        }

        scan += size;
    }

    // Rebuild free list with a single block at the end
    resetFreeListForCompaction(tenured.free_list, data_dest, tenured.end);

    // Compact code heap if present
    if (gc.vm.code) |code| {
        if (code_marks) |marks| {
            var code_dest: Cell = code_start;
            var code_scan: Cell = code_start;

            while (code_scan < code_end) {
                const size = if (marks.isMarked(code_scan))
                    (@as(*code_blocks.CodeBlock, @ptrFromInt(code_scan))).size()
                else
                    marks.unmarkedBlockSize(code_scan);

                if (size == 0) break;

                if (marks.isMarked(code_scan)) {
                    code_finger = code_scan + size;
                    if (code_dest != code_scan) {
                        memmoveBytes(code_dest, code_scan, size);
                    }

                    const new_block: *code_blocks.CodeBlock = @ptrFromInt(code_dest);
                    const old_entry_point = code_scan + @sizeOf(code_blocks.CodeBlock);

                    // Fix data pointers in the block header
                    new_block.owner = fixupSlotValue(&fixup, new_block.owner);
                    new_block.parameters = fixupSlotValue(&fixup, new_block.parameters);
                    new_block.relocation = fixupSlotValue(&fixup, new_block.relocation);

                    // Fix embedded literals and code pointers unless uninitialized
                    if (!code.isUninitializedAddress(@intFromPtr(new_block))) {
                        _ = updateInstructionOperandsForCompaction(gc, new_block, old_entry_point, &fixup);
                    }

                    code_dest += size;
                }

                code_scan += size;
            }

            if (code.free_list) |alloc| {
                resetFreeListForCompaction(alloc, code_dest, code_end);
                alloc.validateFreeList();
            }
        }
    }

    // When not compacting code, still fix data pointers in live code blocks
    // (owner, parameters, relocation, embedded literals) since data objects moved.
    if (!compact_code_heap) {
        if (gc.vm.code) |code| {
            if (code.marks) |marks| {
                var code_scan: Cell = code.code_start;
                const code_end_addr2 = code.code_start + code.code_size;
                while (code_scan < code_end_addr2) {
                    const block: *code_blocks.CodeBlock = @ptrFromInt(code_scan);
                    const blk_size = block.size();
                    if (blk_size == 0) break;

                    if (marks.isMarked(code_scan) and !block.isFree()) {
                        block.owner = fixupSlotValue(&fixup, block.owner);
                        block.parameters = fixupSlotValue(&fixup, block.parameters);
                        block.relocation = fixupSlotValue(&fixup, block.relocation);

                        if (!code.isUninitializedAddress(code_scan)) {
                            if (updateInstructionOperandsForCompaction(gc, block, block.entryPoint(), &fixup)) {
                                block.flushIcache();
                            }
                        }
                    }

                    code_scan += blk_size;
                }
            }
        }
    }

    // Fix up uninitialized_blocks map values (data pointers).
    // not just code compaction. Without this, values in the map become stale
    // after data-only compaction when the pointed-to objects move.
    if (!compact_code_heap) {
        if (gc.vm.code) |code| {
            var uninit_iter = code.uninitialized_blocks.iterator();
            while (uninit_iter.next()) |entry| {
                entry.value_ptr.* = fixupSlotValue(&fixup, entry.value_ptr.*);
            }
        }
    }

    // Fix up all roots (data pointers)
    for (&gc.vm.vm_asm.special_objects) |*slot| {
        fixupSlot(&fixup, slot);
    }

    for (gc.vm.active_contexts.items) |ctx| {
        fixupContextRoots(gc, ctx, &fixup);
    }

    {
        const ctx = gc.vm.vm_asm.ctx;
        if (!ctx.isActive()) {
            fixupContextRoots(gc, ctx, &fixup);
        }
    }


    for (gc.vm.data_roots.items) |root_ptr| {
        fixupSlot(&fixup, root_ptr);
    }

    if (gc.vm.callbacks) |callback_heap| {
        const seg = callback_heap.segment orelse null;
        if (seg) |s| {
            var current = s.start;
            while (current < s.end) {
                const block: *code_blocks.CodeBlock = @ptrFromInt(current);
                const block_size = block.size();
                if (block_size == 0) break;

                if (!block.isFree()) {
                    // Owner is a tagged data pointer
                    block.owner = fixupSlotValue(&fixup, block.owner);
                }

                current += block_size;
            }
        }
    }

    // Fix return addresses in live callstacks after code compaction
    // (only needed when code blocks moved)
    if (compact_code_heap) {
        for (gc.vm.active_contexts.items) |ctx| {
            fixupCallstackReturnAddresses(gc, ctx, &fixup);
        }

        {
            const ctx = gc.vm.vm_asm.ctx;
            if (!ctx.isActive()) {
                fixupCallstackReturnAddresses(gc, ctx, &fixup);
            }
        }


        // Update code roots after code compaction (inline cache call sites)
        if (code_marks) |marks| {
            updateCodeRootsForCompaction(gc, marks);
        }

        // Update callback stubs after code compaction
        if (gc.vm.callbacks) |callback_heap| {
            if (callback_heap.segment) |seg| {
                var current = seg.start;
                while (current < seg.end) {
                    const block: *code_blocks.CodeBlock = @ptrFromInt(current);
                    const block_size = block.size();
                    if (block_size == 0) break;

                    if (!block.isFree()) {
                        callback_heap.update(block, gc.vm);
                    }

                    current += block_size;
                }
            }
        }
    }

    // Rebuild code block index and clear remembered sets
    if (gc.vm.code) |code| {
        if (compact_code_heap) {
            code.initializeAllBlocksSet() catch @panic("OOM");
            // scan_literals/scan_code_ptrs are indexed by block address.
            // After code compaction they must be rebuilt for the new layout.
            code.rebuildScanFlags(gc.allocator);
        }
        code.clearRememberedSets();
    }

    // Clear cards/decks after compaction
    sweep_mod.resetTenuredCards(gc);

    // Flush instruction cache after code compaction.
    // Data-only compaction flushes only blocks whose instruction operands changed.
    if (compact_code_heap) {
        if (gc.vm.code) |code| {
            icache.flushICache(code.code_start, code.code_size);
        }
    }
}
