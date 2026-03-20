const std = @import("std");
const builtin = @import("builtin");

const code_blocks = @import("code_blocks.zig");
const contexts = @import("contexts.zig");
const data_heap_mod = @import("data_heap.zig");
const free_list = @import("free_list.zig");
const layouts = @import("layouts.zig");
const mark_bits = @import("mark_bits.zig");
const slot_visitor = @import("slot_visitor.zig");
const spill_slots = @import("spill_slots.zig");
const vm_mod = @import("vm.zig");
const card_scan = @import("card_scan.zig");
const compact = @import("compact.zig");
const callstack_lookup = @import("callstack_lookup.zig");
const mark_mod = @import("mark.zig");
const sweep_mod = @import("sweep.zig");
const write_barrier = @import("write_barrier.zig");

const Cell = layouts.Cell;
const Context = contexts.Context;
const DataHeap = data_heap_mod.DataHeap;
const FactorVM = vm_mod.FactorVM;

pub fn objectOrFreeSize(addr: Cell) Cell {
    const obj: *const layouts.Object = @ptrFromInt(addr);
    if (obj.isFree()) {
        return obj.header & ~@as(Cell, 7);
    }
    return free_list.objectSizeFromHeader(addr);
}

pub const GCOp = vm_mod.GCOp;
pub const GCPhase = vm_mod.GCPhase;

pub const GarbageCollector = struct {
    allocator: std.mem.Allocator,
    vm: *FactorVM,
    heap: *DataHeap,

    mark_stack: std.ArrayList(Cell) = .empty,

    collections: Cell = 0,

    last_nursery_survival: f32 = 0.0,
    last_aging_survival: f32 = 0.0,

    current_event: ?*vm_mod.GCEvent = null,
    event_storage: vm_mod.GCEvent = undefined,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, vm: *FactorVM, heap: *DataHeap) Self {
        var self = Self{
            .allocator = allocator,
            .vm = vm,
            .heap = heap,
        };
        self.mark_stack.ensureTotalCapacity(allocator, 8192) catch {};
        return self;
    }

    pub fn deinit(self: *Self) void {
        self.mark_stack.deinit(self.allocator);
    }

    pub fn gc(self: *Self, op: GCOp) !void {
        var current_op = op;

        if (self.vm.gc_events != null) {
            self.event_storage = vm_mod.GCEvent.init(op, self.vm);
            self.current_event = &self.event_storage;
        }
        defer {
            if (self.current_event) |event| {
                event.endedGC(self.vm);
                if (self.vm.gc_events) |events| {
                    events.append(self.vm.allocator, event.*) catch {};
                }
                self.current_event = null;
            }
        }

        while (true) {
            if (self.current_event) |event| {
                event.op = @intFromEnum(current_op);
            }

            const success = switch (current_op) {
                .collect_nursery => self.collectNursery(),
                .collect_aging => blk: {
                    const ok = self.collectAging();
                    if (ok and self.heap.isHighFragmentation()) {
                        if (self.current_event) |event| {
                            event.op = @intFromEnum(GCOp.collect_full);
                        }
                        self.collectFull(false);
                    }
                    break :blk ok;
                },
                .collect_to_tenured => blk: {
                    const ok = self.collectToTenured();
                    if (ok and self.heap.isHighFragmentation()) {
                        if (self.current_event) |event| {
                            event.op = @intFromEnum(GCOp.collect_full);
                        }
                        self.collectFull(false);
                    }
                    break :blk ok;
                },
                .collect_full => blk: {
                    self.collectFull(false);
                    break :blk true;
                },
                .collect_compact => blk: {
                    self.collectCompact();
                    break :blk true;
                },
                .collect_growing_data_heap => blk: {
                    try self.collectGrowingDataHeap(0);
                    break :blk true;
                },
            };

            if (success) break;

            current_op = switch (current_op) {
                .collect_nursery => .collect_aging,
                .collect_aging => .collect_to_tenured,
                .collect_to_tenured => .collect_full,
                else => {
                    return error.GCFailed;
                },
            };
        }
    }

    pub fn collect(self: *Self, op: GCOp) void {
        self.vm.syncContextFromRegisters();

        const need_unlock = self.vm.callstackNeedsGuardUnlock() or op == .collect_compact;
        if (need_unlock) {
            if (self.vm.vm_asm.ctx.callstack_seg) |seg| {
                seg.setBorderLocked(false) catch {};
            }
        }
        defer {
            if (need_unlock) {
                if (self.vm.vm_asm.ctx.callstack_seg) |seg| {
                    seg.setBorderLocked(true) catch {};
                }
            }
        }

        self.gc(op) catch @panic("GC failed");
    }

    fn updateSurvivalRate(used: Cell, copied: Cell) f32 {
        if (used == 0) return 0.0;
        const rate = @as(f32, @floatFromInt(copied)) / @as(f32, @floatFromInt(used));
        return @min(rate, 1.0);
    }

    fn adaptSize(current: Cell, survival: f32, min_size: Cell, max_size: Cell) Cell {
        if (survival == 0.0) return current; // No data yet
        var new_size = current;
        if (survival > 0.70) {
            new_size = current + current / 2;
        } else if (survival < 0.15) {
            new_size = current / 2;
        }
        new_size = @max(min_size, @min(new_size, max_size));
        return layouts.alignCell(new_size, layouts.data_alignment);
    }

    fn adaptiveYoungSize(self: *Self) Cell {
        const min_size = DataHeap.default_young_size / 4; // 1MB
        const max_size = DataHeap.default_young_size * 8; // 32MB
        return adaptSize(self.heap.young_size, self.last_nursery_survival, min_size, max_size);
    }

    fn adaptiveAgingSize(self: *Self) Cell {
        const min_size = DataHeap.default_aging_size / 4; // 4MB
        const max_size = DataHeap.default_aging_size * 8; // 128MB
        return adaptSize(self.heap.aging_size, self.last_aging_survival, min_size, max_size);
    }

    fn collectNursery(self: *Self) bool {
        self.heap.nursery.here = self.vm.vm_asm.nursery.here;

        const aging = &self.heap.aging;
        const nursery = &self.vm.vm_asm.nursery;
        const nursery_used: Cell = nursery.here - nursery.start;

        const scan_start = aging.here;

        var destination = slot_visitor.CopyingDestination{
            .bump_here = &aging.here,
            .bump_end = aging.end,
            .bump_object_start = &aging.object_start,
            .source_start = nursery.start,
            .source_end = nursery.end,
            .code_heap = self.vm.code,
        };

        self.visitAllRoots(&destination);

        if (self.current_event) |event| event.resetTimer();
        card_scan.scanCards(self, &self.heap.tenured, write_barrier.card_points_to_nursery, write_barrier.card_points_to_nursery, &destination, aging.start, aging.end);
        card_scan.scanCardsGeneration(self, self.heap.aging.start, scan_start, &self.heap.aging.object_start, write_barrier.card_points_to_nursery, 0xff, &destination, 0, 0);

        if (self.current_event) |event| event.endedPhase(.card_scan);

        if (self.current_event) |event| event.resetTimer();
        card_scan.scanCodeHeapRoots(self, &destination, .nursery);
        if (self.current_event) |event| event.endedPhase(.code_scan);

        cheneyAlgorithm(aging, scan_start, &destination);
        if (destination.allocation_failed) {
            return false;
        }

        const copied_bytes: Cell = aging.here - scan_start;
        self.last_nursery_survival = updateSurvivalRate(nursery_used, copied_bytes);

        nursery.flush();
        self.vm.vm_asm.nursery.here = nursery.here;
        self.heap.nursery_collections += 1;
        if (@import("builtin").mode == .Debug) {
            self.fillUnusedStacks();
        }

        if (self.vm.code) |code| {
            code.remembered_sets.clearNurseryOnly();
        }

        return true;
    }

    fn collectAging(self: *Self) bool {

        self.mark_stack.clearRetainingCapacity();

        self.heap.nursery.here = self.vm.vm_asm.nursery.here;
        const nursery = &self.vm.vm_asm.nursery;
        const aging = &self.heap.aging;
        const aging_used: Cell = aging.here - aging.start;

        var copy_ctx = CopyContext{
            .gc = self,
            .space = &self.heap.tenured,
        };

        var promote_destination = slot_visitor.CopyingDestination{
            .allocateFn = copyAllocate,
            .postCopyFn = copyPostCopy,
            .ptr = @ptrCast(&copy_ctx),
            .source_start = nursery.start,
            .source_end = nursery.end,
            .source2_start = aging.start,
            .source2_end = aging.end,
            .code_heap = self.vm.code,
        };

        if (self.current_event) |event| event.resetTimer();
        card_scan.scanCards(self, &self.heap.tenured, write_barrier.card_points_to_aging, 0xff, &promote_destination, 0, 0);
        if (self.current_event) |event| event.endedPhase(.card_scan);

        if (self.current_event) |event| event.resetTimer();
        card_scan.scanCodeHeapRoots(self, &promote_destination, .aging);
        if (self.current_event) |event| event.endedPhase(.code_scan);

        if (self.current_event) |event| event.resetTimer();
        self.visitCopiedObjects(&promote_destination);
        if (self.current_event) |event| event.endedPhase(.marking);

        if (promote_destination.allocation_failed) {
            return false;
        }

        const old_aging_start = aging.start;
        const old_aging_end = aging.end;
        const old_nursery_start = nursery.start;
        const old_nursery_end = nursery.end;

        const tmp = self.heap.aging;
        self.heap.aging = self.heap.aging_semispace;
        self.heap.aging_semispace = tmp;
        self.heap.resetAging();

        const target = &self.heap.aging;
        const scan_start = target.here;

        var destination = slot_visitor.CopyingDestination{
            .bump_here = &target.here,
            .bump_end = target.end,
            .bump_object_start = &target.object_start,
            .source_start = old_nursery_start,
            .source_end = old_nursery_end,
            .source2_start = old_aging_start,
            .source2_end = old_aging_end,
            .code_heap = self.vm.code,
        };

        if (self.current_event) |event| event.resetTimer();
        self.visitAllRoots(&destination);
        if (self.current_event) |event| event.endedPhase(.code_sweep);

        if (self.current_event) |event| event.resetTimer();
        cheneyAlgorithm(target, scan_start, &destination);
        if (self.current_event) |event| event.endedPhase(.data_sweep);

        if (destination.allocation_failed) {
            return false;
        }

        const aging_survivors: Cell = target.here - target.start;
        self.last_aging_survival = updateSurvivalRate(aging_used, aging_survivors);

        self.vm.vm_asm.nursery.reset();
        self.heap.nursery.here = self.vm.vm_asm.nursery.here;

        self.heap.aging_collections += 1;

        if (self.vm.code) |code| {
            code.remembered_sets.clear();
        }

        return true;
    }

    fn collectToTenured(self: *Self) bool {
        self.mark_stack.clearRetainingCapacity();

        self.heap.nursery.here = self.vm.vm_asm.nursery.here;
        const nursery = &self.vm.vm_asm.nursery;
        const aging = &self.heap.aging;
        const aging_semi = &self.heap.aging_semispace;

        var copy_ctx = CopyContext{
            .gc = self,
            .space = &self.heap.tenured,
        };

        var destination = slot_visitor.CopyingDestination{
            .allocateFn = copyAllocate,
            .postCopyFn = copyPostCopy,
            .ptr = @ptrCast(&copy_ctx),
            .source_start = nursery.start,
            .source_end = nursery.end,
            .source2_start = aging.start,
            .source2_end = aging.end,
            .source3_start = aging_semi.start,
            .source3_end = aging_semi.end,
            .code_heap = self.vm.code,
        };

        self.visitAllRoots(&destination);

        if (self.current_event) |event| event.resetTimer();
        card_scan.scanCards(self, &self.heap.tenured, write_barrier.card_points_to_aging, 0xff, &destination, 0, 0);
        if (self.current_event) |event| event.endedPhase(.card_scan);

        if (self.current_event) |event| event.resetTimer();
        card_scan.scanCodeHeapRoots(self, &destination, .both);
        if (self.current_event) |event| event.endedPhase(.code_scan);

        self.visitCopiedObjects(&destination);

        if (destination.allocation_failed) {
            return false;
        }

        self.vm.vm_asm.nursery.reset();
        self.heap.nursery.here = self.vm.vm_asm.nursery.here;
        self.heap.resetAging();

        if (self.vm.code) |code| {
            code.remembered_sets.clear();
        }

        return true;
    }

    pub fn collectFull(self: *Self, compact_p: bool) void {
        if (self.current_event) |event| event.resetTimer();
        const ok = self.markPhaseFull_();
        if (self.current_event) |event| event.endedPhase(.marking);
        if (!ok) {
            _ = self.collectGrowingDataHeap(0) catch @panic("OOM");
            self.heap.full_collections += 1;
            return;
        }

        sweep_mod.sweepPhase(self);

        if (self.heap.isLowMemory()) {
            if (self.current_event) |event| {
                event.op = @intFromEnum(GCOp.collect_growing_data_heap);
            }
            _ = self.collectGrowingDataHeap(0) catch @panic("OOM");
        } else if (compact_p or self.heap.isHighFragmentation()) {
            if (self.current_event) |event| {
                event.op = @intFromEnum(GCOp.collect_compact);
            }
            if (self.current_event) |event| event.resetTimer();
            compact.compactPhase(self, true);
            if (self.current_event) |event| event.endedPhase(.data_compaction);
        }

        self.heap.full_collections += 1;
    }

    fn markPhaseFull_(self: *Self) bool {
        self.heap.tenured.clearMarks();
        if (self.vm.code) |code| {
            if (code.marks == null) {
                code.ensureMarks(self.allocator) catch @panic("OOM");
            }
            code.clearMarks();
        }

        self.mark_stack.clearRetainingCapacity();

        self.heap.nursery.here = self.vm.vm_asm.nursery.here;
        const nursery = &self.vm.vm_asm.nursery;
        const aging = &self.heap.aging;
        const aging_semi = &self.heap.aging_semispace;
        var copy_ctx = CopyContext{
            .gc = self,
            .space = &self.heap.tenured,
        };
        var destination = slot_visitor.CopyingDestination{
            .allocateFn = copyAllocate,
            .postCopyFn = null,
            .ptr = @ptrCast(&copy_ctx),
            .source_start = nursery.start,
            .source_end = nursery.end,
            .source2_start = aging.start,
            .source2_end = aging.end,
            .source3_start = aging_semi.start,
            .source3_end = aging_semi.end,
            .code_heap = self.vm.code,
        };

        var ctx = mark_mod.FullMarkContext{
            .gc = self,
            .destination = &destination,
            .tenured = &self.heap.tenured,
        };

        mark_mod.fullMarkAllRoots(self, &ctx);
        mark_mod.fullDrainMarkStack(self, &ctx);

        if (destination.allocation_failed) {
            return false;
        }

        self.vm.vm_asm.nursery.reset();
        self.heap.nursery.here = self.vm.vm_asm.nursery.here;
        self.heap.resetAging();

        if (self.vm.code) |code| {
            code.remembered_sets.clear();
        }

        return true;
    }

    fn collectCompact(self: *Self) void {
        if (self.current_event) |event| event.resetTimer();
        const ok = self.markPhaseFull_();
        if (self.current_event) |event| event.endedPhase(.marking);
        if (!ok) {
            _ = self.collectGrowingDataHeap(0) catch @panic("OOM");
            self.heap.full_collections += 1;
            return;
        }

        if (self.current_event) |event| event.resetTimer();
        compact.compactPhase(self, true);
        if (self.current_event) |event| event.endedPhase(.data_compaction);

        if (self.heap.isHighFragmentation()) {
            _ = self.collectGrowingDataHeap(0) catch @panic("OOM");
        }

        self.heap.full_collections += 1;
    }

    pub fn collectGrowingDataHeap(self: *Self, requested_size: Cell) !void {
        const old_heap = self.heap;

        old_heap.nursery.here = self.vm.vm_asm.nursery.here;

        const old_nursery_start = old_heap.nursery.start;
        const old_nursery_end = old_heap.nursery.end;
        const old_aging_start = old_heap.aging.start;
        const old_aging_end = old_heap.aging.end;
        const old_aging_semi_start = old_heap.aging_semispace.start;
        const old_aging_semi_end = old_heap.aging_semispace.end;
        const old_tenured_start = old_heap.tenured.start;
        const old_tenured_end = old_heap.tenured.end;

        const new_young = self.adaptiveYoungSize();
        const new_aging = self.adaptiveAgingSize();
        const new_heap = try old_heap.growWithSizes(requested_size, new_young, new_aging);

        self.vm.setDataHeap(new_heap);
        self.heap = new_heap;

        self.mark_stack.clearRetainingCapacity();

        var copy_ctx = CopyContext{
            .gc = self,
            .space = &new_heap.tenured,
        };

        var destination = slot_visitor.CopyingDestination{
            .allocateFn = copyAllocate,
            .postCopyFn = copyPostCopy,
            .ptr = @ptrCast(&copy_ctx),
            .source_start = old_nursery_start,
            .source_end = old_nursery_end,
            .source2_start = old_aging_start,
            .source2_end = old_aging_end,
            .source3_start = old_aging_semi_start,
            .source3_end = old_aging_semi_end,
            .source4_start = old_tenured_start,
            .source4_end = old_tenured_end,
            .code_heap = self.vm.code,
        };

        self.visitAllRoots(&destination);

        card_scan.scanAllCodeBlocksForCopy(self, &destination);

        self.visitCopiedObjects(&destination);

        if (destination.allocation_failed) {
            return error.GCFailed;
        }

        self.vm.vm_asm.nursery.reset();
        new_heap.nursery.here = self.vm.vm_asm.nursery.here;
        new_heap.resetAging();

        if (self.vm.code) |code| {
            code.remembered_sets.clear();
        }
        self.updateCodeBlockExternalRelocations();

        self.freeOldHeap(old_heap);
    }
    fn updateCodeBlockExternalRelocations(self: *Self) void {
        const code = self.vm.code orelse return;
        code.flushPending();
        const cards_offset: i64 = @bitCast(self.vm.vm_asm.cards_offset);
        const decks_offset: i64 = @bitCast(self.vm.vm_asm.decks_offset);
        const has_uninitialized = code.uninitialized_blocks.count() != 0;

        for (code.all_blocks_sorted.items) |block_addr| {
            const block: *code_blocks.CodeBlock = @ptrFromInt(block_addr);
            if (block.isFree()) continue;
            if (has_uninitialized and code.isUninitializedAddress(block_addr)) continue;
            if (block.relocation == layouts.false_object) continue;
            if (!layouts.hasTag(block.relocation, .byte_array)) continue;

            const reloc_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(block.relocation));
            const reloc_cap = layouts.untagFixnumUnsigned(reloc_ba.capacity);
            if (reloc_cap == 0) continue;

            const reloc_data = reloc_ba.data();
            const reloc_count = reloc_cap / @sizeOf(code_blocks.RelocationEntry);
            var modified = false;

            for (0..reloc_count) |i| {
                const entry_ptr: *const code_blocks.RelocationEntry = @ptrCast(@alignCast(
                    reloc_data + i * @sizeOf(code_blocks.RelocationEntry),
                ));
                const rel_type = entry_ptr.getType();
                if (rel_type == .cards_offset) {
                    var op = code_blocks.InstructionOperand.init(entry_ptr.*, block, 0);
                    if (op.loadValue() != cards_offset) {
                        op.storeValue(cards_offset);
                        modified = true;
                    }
                } else if (rel_type == .decks_offset) {
                    var op = code_blocks.InstructionOperand.init(entry_ptr.*, block, 0);
                    if (op.loadValue() != decks_offset) {
                        op.storeValue(decks_offset);
                        modified = true;
                    }
                }
            }

            if (modified) {
                block.flushIcache();
            }
        }
    }

    fn visitAllRoots(self: *Self, destination: *slot_visitor.CopyingDestination) void {
        for (&self.vm.vm_asm.special_objects) |*slot| {
            visitSlot(slot, destination);
        }

        self.visitContexts(destination);

        for (self.vm.data_roots.items) |root_ptr| {
            visitSlot(root_ptr, destination);
        }

        if (self.vm.callbacks) |callback_heap| {
            const Ctx = struct {
                dest: *slot_visitor.CopyingDestination,
                fn visit(slot: *Cell, ctx: @This()) void {
                    const value = slot.*;
                    if (!layouts.isImmediate(value)) {
                        slot.* = ctx.dest.copy(value);
                    }
                }
            };
            const ctx = Ctx{ .dest = destination };
            callback_heap.iterateOwnersWithCtx(Ctx, Ctx.visit, ctx);
        }

        if (self.vm.code) |code| {
            var iter = code.uninitialized_blocks.iterator();
            while (iter.next()) |entry| {
                const value = entry.value_ptr.*;
                if (!layouts.isImmediate(value)) {
                    entry.value_ptr.* = destination.copy(value);
                }
            }
        }
    }

    fn visitContexts(self: *Self, destination: *slot_visitor.CopyingDestination) void {
        for (self.vm.active_contexts.items) |ctx| {
            self.visitContext(ctx, destination);
        }

        {
            const ctx = self.vm.vm_asm.ctx;
            if (!ctx.isActive()) {
                self.visitContext(ctx, destination);
            }
        }

        // active_contexts during GC. Unused contexts are pooled for reuse
        // and their stacks may contain stale pointers from previous nursery
        // cycles. Visiting them would cause the GC to try to copy poisoned
        // nursery data (0xBA pattern) as valid objects, corrupting aging space.
    }

    fn visitContext(self: *Self, ctx: *Context, destination: *slot_visitor.CopyingDestination) void {
        const Visit = struct {
            fn slot(slot_ptr: *Cell, dest: *slot_visitor.CopyingDestination) void {
                const value = slot_ptr.*;
                if (layouts.isImmediate(value)) return;
                const copied = dest.copy(value);
                if (copied != value) {
                    slot_ptr.* = copied;
                }
            }
        };

        for (&ctx.context_objects) |*slot| {
            Visit.slot(slot, destination);
        }

        self.visitCallstack(ctx, destination);
        if (ctx.datastack_seg) |seg| {
            const min_valid = seg.start -| @sizeOf(Cell);
            std.debug.assert(ctx.datastack >= min_valid and ctx.datastack <= seg.end);
            std.debug.assert((ctx.datastack -% min_valid) % @sizeOf(Cell) == 0);

            if (ctx.datastack >= seg.start) {
                var ptr = seg.start;
                while (ptr <= ctx.datastack) : (ptr += @sizeOf(Cell)) {
                    const slot: *Cell = @ptrFromInt(ptr);
                    Visit.slot(slot, destination);
                }
            }
            if (comptime builtin.mode == .Debug) {
                contexts.fillStackSeg(ctx.datastack, seg, 0xbaadbadd);
            }
        }

        if (ctx.retainstack_seg) |seg| {
            const min_valid_rs = seg.start -| @sizeOf(Cell);
            std.debug.assert(ctx.retainstack >= min_valid_rs and ctx.retainstack <= seg.end);
            std.debug.assert((ctx.retainstack -% min_valid_rs) % @sizeOf(Cell) == 0);

            if (ctx.retainstack >= seg.start) {
                var ptr = seg.start;
                while (ptr <= ctx.retainstack) : (ptr += @sizeOf(Cell)) {
                    const slot: *Cell = @ptrFromInt(ptr);
                    Visit.slot(slot, destination);
                }
            }
            if (comptime builtin.mode == .Debug) {
                contexts.fillStackSeg(ctx.retainstack, seg, 0xdaabdabb);
            }
        }
    }

    fn visitCallstack(self: *Self, ctx: *Context, destination: *slot_visitor.CopyingDestination) void {
        const code_heap = self.vm.code orelse return;
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
            const frame_size = callstack_lookup.Lookup.frameSizeFromAddress(owner, addr);
            const cb: *const code_blocks.CodeBlock = @ptrCast(owner);
            if (cb.blockGcInfo()) |gc_info| {
                const return_address_offset: u32 = @intCast(cb.offset(addr));
                if (lookup.callsiteIndex(gc_info, return_address_offset)) |callsite| {
                    const stack_pointer: [*]Cell = @ptrFromInt(top);
                    const Visit = struct {
                        fn slot(slot_ptr: *Cell, dest: *slot_visitor.CopyingDestination) void {
                            const value = slot_ptr.*;
                            if (layouts.isImmediate(value)) return;
                            const copied = dest.copy(value);
                            if (copied != value) slot_ptr.* = copied;
                        }
                    };
                    spill_slots.visit(*slot_visitor.CopyingDestination, stack_pointer, gc_info, callsite, destination, Visit.slot);
                }
            } else {
                lookup.cached_gc_info = null;
                lookup.cached_callsite_index = null;
            }

            top += frame_size;
        }
    }

    const CopyContext = struct {
        gc: *Self,
        space: *data_heap_mod.TenuredSpace,
    };

    fn copyAllocate(dest: *slot_visitor.CopyingDestination, size: Cell) ?Cell {
        const ctx: *CopyContext = @ptrCast(@alignCast(dest.ptr));
        return ctx.space.allocate(size);
    }

    fn copyPostCopy(dest: *slot_visitor.CopyingDestination, new_addr: Cell) void {
        const ctx: *CopyContext = @ptrCast(@alignCast(dest.ptr));
        ctx.gc.mark_stack.append(ctx.gc.allocator, new_addr) catch @panic("Mark stack overflow");
    }

    fn fillUnusedStacks(self: *Self) void {
        for (self.vm.active_contexts.items) |ctx| {
            fillContextStacks(ctx);
        }
        {
            const ctx = self.vm.vm_asm.ctx;
            if (!ctx.isActive()) {
                fillContextStacks(ctx);
            }
        }
    }

    fn fillContextStacks(ctx: *Context) void {
        if (ctx.datastack_seg) |seg| {
            const fill_start = ctx.datastack + @sizeOf(Cell);
            const fill_end = seg.start + seg.size;
            if (fill_start < fill_end and fill_start > seg.start) {
                const start_ptr: [*]u8 = @ptrFromInt(fill_start);
                const len = fill_end - fill_start;
                if (len < 64 * 1024 * 1024) {
                    @memset(start_ptr[0..len], 0xBA);
                }
            }
        }
        if (ctx.retainstack_seg) |seg| {
            const fill_start = ctx.retainstack + @sizeOf(Cell);
            const fill_end = seg.start + seg.size;
            if (fill_start < fill_end and fill_start > seg.start) {
                const start_ptr: [*]u8 = @ptrFromInt(fill_start);
                const len = fill_end - fill_start;
                if (len < 64 * 1024 * 1024) {
                    @memset(start_ptr[0..len], 0xDA);
                }
            }
        }
    }

    fn visitCopiedObjects(self: *Self, destination: *slot_visitor.CopyingDestination) void {
        while (self.mark_stack.items.len > 0) {
            const addr = self.mark_stack.pop() orelse break;
            _ = slot_visitor.traceAndCopyReturnSize(addr, destination);
        }
    }

    fn freeOldHeap(self: *Self, old_heap: *DataHeap) void {
        old_heap.tenured.deinit();

        const vm_cards = self.vm.cards_array;
        const vm_decks = self.vm.decks_array;
        const old_cards_ptr = old_heap.cards.cards.ptr;
        const old_decks_ptr = old_heap.decks.decks.ptr;

        const cards_owned_by_vm = if (vm_cards) |cards| cards.ptr == old_cards_ptr else false;
        const decks_owned_by_vm = if (vm_decks) |decks| decks.ptr == old_decks_ptr else false;

        if (!cards_owned_by_vm) {
            old_heap.cards.deinit();
        }
        if (!decks_owned_by_vm) {
            old_heap.decks.deinit();
        }

        const seg_start = old_heap.segment.start;
        const seg_end = old_heap.segment.end;

        const seg_via_init = old_heap.segment.alloc_base != old_heap.segment.start or old_heap.segment.alloc_size != old_heap.segment.size;
        if (seg_via_init) {
            old_heap.segment.deinit();
        } else {
            const seg_ptr: [*]align(std.heap.page_size_min) u8 = @ptrFromInt(old_heap.segment.start);
            const seg_slice: []align(std.heap.page_size_min) u8 = seg_ptr[0..@intCast(old_heap.segment.size)];
            _ = std.c.munmap(@ptrCast(seg_slice.ptr), seg_slice.len);
        }

        const aging_in_seg = old_heap.aging.start >= seg_start and old_heap.aging.start < seg_end;
        const nursery_in_seg = old_heap.nursery.start >= seg_start and old_heap.nursery.start < seg_end;

        if (!aging_in_seg) {
            if (old_heap.aging_semispace.start == old_heap.aging.start + old_heap.aging.size) {
                const total = old_heap.aging.size * 2;
                const aging_ptr: [*]align(std.heap.page_size_min) u8 = @ptrFromInt(old_heap.aging.start);
                const slice: []align(std.heap.page_size_min) u8 = aging_ptr[0..@intCast(total)];
                _ = std.c.munmap(@ptrCast(slice.ptr), slice.len);
            } else {
                const aging_ptr1: [*]align(std.heap.page_size_min) u8 = @ptrFromInt(old_heap.aging.start);
                const slice1: []align(std.heap.page_size_min) u8 = aging_ptr1[0..@intCast(old_heap.aging.size)];
                const aging_ptr2: [*]align(std.heap.page_size_min) u8 = @ptrFromInt(old_heap.aging_semispace.start);
                const slice2: []align(std.heap.page_size_min) u8 = aging_ptr2[0..@intCast(old_heap.aging_semispace.size)];
                _ = std.c.munmap(@ptrCast(slice1.ptr), slice1.len);
                _ = std.c.munmap(@ptrCast(slice2.ptr), slice2.len);
            }
        }

        if (!nursery_in_seg) {
            const nursery_ptr: [*]align(std.heap.page_size_min) u8 = @ptrFromInt(old_heap.nursery.start);
            const slice: []align(std.heap.page_size_min) u8 = nursery_ptr[0..@intCast(old_heap.nursery.size)];
            _ = std.c.munmap(@ptrCast(slice.ptr), slice.len);
        }

        old_heap.allocator.destroy(old_heap);
    }
};

fn visitSlot(slot: *Cell, destination: *slot_visitor.CopyingDestination) void {
    const value = slot.*;

    if (layouts.isImmediate(value)) {
        return;
    }

    const new_value = destination.copy(value);
    if (new_value != value) slot.* = new_value;
}

fn cheneyAlgorithm(space: anytype, scan_start: Cell, destination: *slot_visitor.CopyingDestination) void {
    var scan = scan_start;

    while (scan < space.here) {
        const size = slot_visitor.traceAndCopyReturnSize(scan, destination);
        if (size == 0) break;
        scan += size;
    }
}

test "gc write barrier marks card/deck and dirty list" {
    const allocator = std.testing.allocator;

    var vm = try vm_mod.FactorVM.init(allocator);
    vm.vm_asm.ctx = try vm.newContext();
    vm.vm_asm.spare_ctx = try vm.newContext();
    defer {
        vm.cards_array = null;
        vm.decks_array = null;
        vm.deinit();
    }

    const heap = try data_heap_mod.DataHeap.init(allocator, 4096, 4096, 8192);
    defer heap.deinit();

    vm.setDataHeap(heap);

    const slot_addr: Cell = heap.tenured.start + 32;
    const slot_ptr: *Cell = @ptrFromInt(slot_addr);

    const card_idx: Cell = slot_addr >> @intCast(vm_mod.card_bits);
    const deck_idx: Cell = slot_addr >> @intCast(vm_mod.deck_bits);
    const card_ptr: *u8 = @ptrFromInt(vm.vm_asm.cards_offset +% card_idx);
    const deck_ptr: *u8 = @ptrFromInt(vm.vm_asm.decks_offset +% deck_idx);

    card_ptr.* = 0;
    deck_ptr.* = 0;

    vm.writeBarrier(slot_ptr);

    try std.testing.expectEqual(write_barrier.card_mark_mask, card_ptr.*);
    try std.testing.expectEqual(write_barrier.card_mark_mask, deck_ptr.*);
}

test "gc scanCardsGeneration scans aging cards for nursery references" {
    const allocator = std.testing.allocator;

    var vm = try vm_mod.FactorVM.init(allocator);
    vm.vm_asm.ctx = try vm.newContext();
    vm.vm_asm.spare_ctx = try vm.newContext();
    defer {
        vm.cards_array = null;
        vm.decks_array = null;
        vm.deinit();
    }

    const heap = try data_heap_mod.DataHeap.init(allocator, 4096, 4096, 8192);
    defer heap.deinit();

    vm.setDataHeap(heap);
    var gc_instance = GarbageCollector.init(allocator, vm, heap);
    defer gc_instance.deinit();

    const nursery_cap: Cell = 1;
    const nursery_size = layouts.alignCell(@sizeOf(layouts.Array) + nursery_cap * @sizeOf(Cell), layouts.data_alignment);
    const nursery_addr = heap.allocateNursery(nursery_size) orelse return;
    const nursery_arr: *layouts.Array = @ptrFromInt(nursery_addr);
    nursery_arr.header = @as(Cell, @intFromEnum(layouts.TypeTag.array)) << 2;
    nursery_arr.capacity = layouts.tagFixnum(@intCast(nursery_cap));
    @memset(nursery_arr.data()[0..nursery_cap], layouts.false_object);
    const nursery_tagged = nursery_addr | @intFromEnum(layouts.TypeTag.array);

    const aging_cap: Cell = 1;
    const aging_size = layouts.alignCell(@sizeOf(layouts.Array) + aging_cap * @sizeOf(Cell), layouts.data_alignment);
    const aging_addr = heap.allocateAging(aging_size) orelse return;
    const aging_arr: *layouts.Array = @ptrFromInt(aging_addr);
    aging_arr.header = @as(Cell, @intFromEnum(layouts.TypeTag.array)) << 2;
    aging_arr.capacity = layouts.tagFixnum(@intCast(aging_cap));
    aging_arr.data()[0] = nursery_tagged;

    const slot_ptr = &aging_arr.data()[0];
    vm.writeBarrier(slot_ptr);

    const old_aging_h = heap.aging.here;

    var destination = slot_visitor.CopyingDestination{
        .bump_here = &heap.aging.here,
        .bump_end = heap.aging.end,
        .bump_object_start = &heap.aging.object_start,
        .source_start = heap.nursery.start,
        .source_end = heap.nursery.end,
    };

    const slot_addr = @intFromPtr(slot_ptr);
    const card_ptr: *u8 = @ptrFromInt(vm.vm_asm.cards_offset +% (slot_addr >> @intCast(vm_mod.card_bits)));
    const deck_ptr: *u8 = @ptrFromInt(vm.vm_asm.decks_offset +% (slot_addr >> @intCast(vm_mod.deck_bits)));
    const mask = write_barrier.card_points_to_nursery;
    try std.testing.expect((card_ptr.* & mask) != 0);
    try std.testing.expect((deck_ptr.* & mask) != 0);

    card_scan.scanCardsGeneration(
        &gc_instance,
        heap.aging.start,
        old_aging_h,
        &heap.aging.object_start,
        write_barrier.card_points_to_nursery,
        0xff,
        &destination,
        0,
        0,
    );

    const new_value = aging_arr.data()[0];
    try std.testing.expect(new_value != nursery_tagged);
    const new_addr = layouts.UNTAG(new_value);
    try std.testing.expect(new_addr >= heap.aging.start and new_addr < heap.aging.here);
    try std.testing.expect((card_ptr.* & mask) == 0);
    try std.testing.expect(!destination.allocation_failed);
}

test "gc scanCards updates tenured slot spanning card" {
    const allocator = std.testing.allocator;

    var vm = try vm_mod.FactorVM.init(allocator);
    vm.vm_asm.ctx = try vm.newContext();
    vm.vm_asm.spare_ctx = try vm.newContext();
    defer {
        vm.cards_array = null;
        vm.decks_array = null;
        vm.deinit();
    }

    const heap = try data_heap_mod.DataHeap.init(allocator, 4096, 4096, 8192);
    defer heap.deinit();

    vm.setDataHeap(heap);

    if (heap.segment.start < 0x100000000 or heap.segment.start > 0x800000000) return;

    var gc_instance = GarbageCollector.init(allocator, vm, heap);

    const nursery_cap: Cell = 1;
    const nursery_size = layouts.alignCell(@sizeOf(layouts.Array) + nursery_cap * @sizeOf(Cell), layouts.data_alignment);
    const nursery_addr = heap.allocateNursery(nursery_size) orelse return;
    const nursery_arr: *layouts.Array = @ptrFromInt(nursery_addr);
    nursery_arr.header = @as(Cell, @intFromEnum(layouts.TypeTag.array)) << 2;
    nursery_arr.capacity = layouts.tagFixnum(@intCast(nursery_cap));
    @memset(nursery_arr.data()[0..nursery_cap], layouts.false_object);
    const nursery_tagged = nursery_addr | @intFromEnum(layouts.TypeTag.array);

    const tenured_cap: Cell = 31; // slot 30 starts at next card boundary when object is card-aligned
    const tenured_size = layouts.alignCell(@sizeOf(layouts.Array) + tenured_cap * @sizeOf(Cell), layouts.data_alignment);
    const tenured_addr = heap.allocateTenured(tenured_size) orelse return;
    const tenured_arr: *layouts.Array = @ptrFromInt(tenured_addr);
    tenured_arr.header = @as(Cell, @intFromEnum(layouts.TypeTag.array)) << 2;
    tenured_arr.capacity = layouts.tagFixnum(@intCast(tenured_cap));
    @memset(tenured_arr.data()[0..tenured_cap], layouts.false_object);

    const slot_index: usize = 30;
    tenured_arr.data()[slot_index] = nursery_tagged;

    const slot_addr = @intFromPtr(&tenured_arr.data()[slot_index]);
    const obj_card = tenured_addr >> @intCast(vm_mod.card_bits);
    const slot_card = slot_addr >> @intCast(vm_mod.card_bits);
    try std.testing.expect(slot_card > obj_card);

    vm.writeBarrier(&tenured_arr.data()[slot_index]);

    var destination = slot_visitor.CopyingDestination{
        .bump_here = &heap.aging.here,
        .bump_end = heap.aging.end,
        .bump_object_start = &heap.aging.object_start,
        .source_start = heap.nursery.start,
        .source_end = heap.nursery.end,
    };

    const card_ptr: *u8 = @ptrFromInt(vm.vm_asm.cards_offset +% (slot_addr >> @intCast(vm_mod.card_bits)));
    const deck_ptr: *u8 = @ptrFromInt(vm.vm_asm.decks_offset +% (slot_addr >> @intCast(vm_mod.deck_bits)));
    const mask = write_barrier.card_points_to_nursery;
    try std.testing.expect((card_ptr.* & mask) != 0);
    try std.testing.expect((deck_ptr.* & mask) != 0);

    card_scan.scanCards(&gc_instance, &heap.tenured, write_barrier.card_points_to_nursery, write_barrier.card_points_to_nursery, &destination, 0, 0);

    try std.testing.expect((card_ptr.* & mask) == 0);
    try std.testing.expect(!destination.allocation_failed);
}

test "gc copying destination moves nursery object" {
    const allocator = std.testing.allocator;

    var vm = try vm_mod.FactorVM.init(allocator);
    vm.vm_asm.ctx = try vm.newContext();
    vm.vm_asm.spare_ctx = try vm.newContext();
    defer {
        vm.cards_array = null;
        vm.decks_array = null;
        vm.deinit();
    }

    const heap = try data_heap_mod.DataHeap.init(allocator, 4096, 4096, 8192);
    defer heap.deinit();

    vm.setDataHeap(heap);

    if (heap.segment.start < 0x100000000 or heap.segment.start > 0x800000000) return;

    const nursery_cap: Cell = 2;
    const nursery_size = layouts.alignCell(@sizeOf(layouts.Array) + nursery_cap * @sizeOf(Cell), layouts.data_alignment);
    const nursery_addr = heap.allocateNursery(nursery_size) orelse return;
    const nursery_arr: *layouts.Array = @ptrFromInt(nursery_addr);
    nursery_arr.header = @as(Cell, @intFromEnum(layouts.TypeTag.array)) << 2;
    nursery_arr.capacity = layouts.tagFixnum(@intCast(nursery_cap));
    @memset(nursery_arr.data()[0..nursery_cap], layouts.false_object);
    const nursery_tagged = nursery_addr | @intFromEnum(layouts.TypeTag.array);

    var destination = slot_visitor.CopyingDestination{
        .bump_here = &heap.aging.here,
        .bump_end = heap.aging.end,
        .bump_object_start = &heap.aging.object_start,
        .source_start = heap.nursery.start,
        .source_end = heap.nursery.end,
    };

    const new_tagged = destination.copy(nursery_tagged);
    const new_addr = layouts.UNTAG(new_tagged);
    try std.testing.expect(new_addr != nursery_addr);
    try std.testing.expect(new_addr >= heap.aging.start and new_addr < heap.aging.end);

    const old_obj: *layouts.Object = @ptrFromInt(nursery_addr);
    try std.testing.expect(old_obj.isForwardingPointer());
}

test "gc clearWriteBarrierRange clears cards and decks" {
    const allocator = std.testing.allocator;

    var vm = try vm_mod.FactorVM.init(allocator);
    vm.vm_asm.ctx = try vm.newContext();
    vm.vm_asm.spare_ctx = try vm.newContext();
    defer {
        vm.cards_array = null;
        vm.decks_array = null;
        vm.deinit();
    }

    const heap = try data_heap_mod.DataHeap.init(allocator, 4096, 4096, 8192);
    defer heap.deinit();

    vm.setDataHeap(heap);

    var gc_instance = GarbageCollector.init(allocator, vm, heap);
    defer gc_instance.deinit();

    const base = heap.segment.start;
    const range_start = base + vm_mod.card_size;
    const range_end = base + (vm_mod.card_size * 3);

    if (vm.cards_array) |cards| {
        const first_card = (range_start - base) >> @intCast(vm_mod.card_bits);
        const last_card = (range_end - base + vm_mod.card_size - 1) >> @intCast(vm_mod.card_bits);
        var ci = first_card;
        while (ci < last_card and ci < cards.len) : (ci += 1) {
            cards[ci] = 0xFF;
        }
    }

    if (vm.decks_array) |decks| {
        const first_deck = (range_start - base) >> @intCast(vm_mod.deck_bits);
        const last_deck = (range_end - base + vm_mod.deck_size - 1) >> @intCast(vm_mod.deck_bits);
        var di = first_deck;
        while (di < last_deck and di < decks.len) : (di += 1) {
            decks[di] = 0xFF;
        }
    }

    sweep_mod.clearWriteBarrierRange(&gc_instance, range_start, range_end);

    if (vm.cards_array) |cards| {
        const first_card = (range_start - base) >> @intCast(vm_mod.card_bits);
        const last_card = (range_end - base + vm_mod.card_size - 1) >> @intCast(vm_mod.card_bits);
        var ci = first_card;
        while (ci < last_card and ci < cards.len) : (ci += 1) {
            try std.testing.expectEqual(@as(u8, 0), cards[ci]);
        }
    }

}
