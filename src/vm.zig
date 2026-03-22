const std = @import("std");
const builtin = @import("builtin");

const bump_allocator = @import("bump_allocator.zig");
const callbacks_mod = @import("callbacks.zig");
const code_blocks_mod = @import("code_blocks.zig");
const contexts = @import("contexts.zig");
const data_heap = @import("data_heap.zig");
const free_list = @import("free_list.zig");
const gc = @import("gc.zig");
const layouts = @import("layouts.zig");
const objects = @import("objects.zig");
const safepoints = @import("safepoints.zig");
const segments = @import("segments.zig");

const Cell = layouts.Cell;
const Fixnum = layouts.Fixnum;

pub const card_bits: Cell = 8;
pub const card_size: Cell = 1 << card_bits; // 256 bytes
pub const deck_bits: Cell = 18;
pub const deck_size: Cell = 1 << deck_bits; // 256 KB

pub const card_mark_mask: u8 = card_points_to_nursery | card_points_to_aging;
pub const card_points_to_nursery: u8 = 0x80;
pub const card_points_to_aging: u8 = 0x40;

pub const DataHeap = data_heap.DataHeap;

pub const CodeBlock = code_blocks_mod.CodeBlock;

pub const CodeHeap = @import("code_heap.zig").CodeHeap;

pub const CodeRoot = struct {
    value: Cell,
    valid: bool = true,
    parent: *FactorVM,

    const Self = @This();

    pub fn init(value: Cell, parent: *FactorVM) Self {
        return .{ .value = value, .valid = true, .parent = parent };
    }

    pub fn register(self: *Self) void {
        self.parent.code_roots.append(self.parent.allocator, self) catch @panic("OOM");
    }

    pub fn deinit(self: *Self) void {
        if (self.parent.code_roots.items.len == 0) return;
        const last = self.parent.code_roots.items[self.parent.code_roots.items.len - 1];
        std.debug.assert(last == self);
        _ = self.parent.code_roots.pop();
    }
};

pub const DataRootStack = std.ArrayList(*Cell);

pub const CallbackHeap = callbacks_mod.CallbackHeap;

pub const GCState = struct {
    op: GCOp,
};

pub const GCOp = enum {
    collect_nursery,
    collect_aging,
    collect_to_tenured,
    collect_full,
    collect_compact,
    collect_growing_data_heap,
};

pub const GCPhase = enum(u32) {
    card_scan = 0,
    code_scan = 1,
    data_sweep = 2,
    code_sweep = 3,
    data_compaction = 4,
    marking = 5,
};

/// Contains: nursery (copying-sizes), aging (copying-sizes),
/// tenured (mark-sweep-sizes), cards, decks, mark-stack.
pub const DataHeapRoom = extern struct {
    nursery_size: Cell,
    nursery_occupied: Cell,
    nursery_free: Cell,
    aging_size: Cell,
    aging_occupied: Cell,
    aging_free: Cell,
    tenured_size: Cell,
    tenured_occupied: Cell,
    tenured_total_free: Cell,
    tenured_contiguous_free: Cell,
    tenured_free_block_count: Cell,
    cards: Cell,
    decks: Cell,
    mark_stack: Cell,
};

pub const AllocatorRoom = extern struct {
    size: Cell,
    occupied_space: Cell,
    total_free: Cell,
    contiguous_free: Cell,
    free_block_count: Cell,
};

pub const GCEvent = extern struct {
    comptime {
        std.debug.assert(@sizeOf(DataHeapRoom) == 14 * @sizeOf(Cell)); // 112
        std.debug.assert(@sizeOf(AllocatorRoom) == 5 * @sizeOf(Cell)); // 40
        std.debug.assert(@sizeOf(GCEvent) == 408);
    }
    op: u32,
    data_heap_before: DataHeapRoom,
    code_heap_before: AllocatorRoom,
    data_heap_after: DataHeapRoom,
    code_heap_after: AllocatorRoom,
    cards_scanned: Cell,
    decks_scanned: Cell,
    code_blocks_scanned: Cell,
    start_time: u64,
    total_time: Cell,
    times: [6]Cell,
    temp_time: u64,

    pub fn init(op: GCOp, vm: *FactorVM) GCEvent {
        const primitives = @import("primitives.zig");
        return GCEvent{
            .op = @intFromEnum(op),
            .data_heap_before = computeDataHeapRoom(vm),
            .code_heap_before = computeCodeHeapRoom(vm),
            .data_heap_after = std.mem.zeroes(DataHeapRoom),
            .code_heap_after = std.mem.zeroes(AllocatorRoom),
            .cards_scanned = 0,
            .decks_scanned = 0,
            .code_blocks_scanned = 0,
            .start_time = primitives.nanoCountMonotonic(),
            .total_time = 0,
            .times = [_]Cell{0} ** 6,
            .temp_time = 0,
        };
    }

    pub fn resetTimer(self: *GCEvent) void {
        const primitives = @import("primitives.zig");
        self.temp_time = primitives.nanoCountMonotonic();
    }

    pub fn endedPhase(self: *GCEvent, phase: GCPhase) void {
        const primitives = @import("primitives.zig");
        const now = primitives.nanoCountMonotonic();
        self.times[@intFromEnum(phase)] += @intCast(now - self.temp_time);
    }

    pub fn endedGC(self: *GCEvent, vm: *FactorVM) void {
        const primitives = @import("primitives.zig");
        const now = primitives.nanoCountMonotonic();
        self.data_heap_after = computeDataHeapRoom(vm);
        self.code_heap_after = computeCodeHeapRoom(vm);
        self.total_time = @intCast(now - self.start_time);
    }
};

fn computeDataHeapRoom(vm: *FactorVM) DataHeapRoom {
    const gc_instance = vm.gc orelse return std.mem.zeroes(DataHeapRoom);
    const data = gc_instance.heap;
    const nursery = &vm.vm_asm.nursery;
    return DataHeapRoom{
        .nursery_size = nursery.size,
        .nursery_occupied = nursery.size - nursery.freeBytes(),
        .nursery_free = nursery.freeBytes(),
        .aging_size = data.aging.size,
        .aging_occupied = data.aging.usedBytes(),
        .aging_free = data.aging.freeBytes(),
        .tenured_size = data.tenured.size,
        .tenured_occupied = data.tenured.size - data.tenured.free_list.free_space,
        .tenured_total_free = data.tenured.free_list.free_space,
        .tenured_contiguous_free = data.tenured.free_list.largestFreeBlock(),
        .tenured_free_block_count = data.tenured.free_list.free_block_count,
        .cards = (data.segment.size + card_size - 1) / card_size,
        .decks = (data.segment.size + deck_size - 1) / deck_size,
        .mark_stack = vm.gc.?.mark_stack.capacity * @sizeOf(Cell),
    };
}

fn computeCodeHeapRoom(vm: *FactorVM) AllocatorRoom {
    const code = vm.code orelse return std.mem.zeroes(AllocatorRoom);
    const alloc = code.free_list orelse return std.mem.zeroes(AllocatorRoom);
    return AllocatorRoom{
        .size = alloc.size,
        .occupied_space = alloc.size - alloc.free_space,
        .total_free = alloc.free_space,
        .contiguous_free = alloc.largestFreeBlock(),
        .free_block_count = alloc.free_block_count,
    };
}

/// Dispatch statistics for profiling inline cache behavior.
pub const DispatchStatistics = extern struct {
    megamorphic_cache_hits: Cell,
    megamorphic_cache_misses: Cell,
    cold_call_to_ic_transitions: Cell,
    ic_to_pic_transitions: Cell,
    pic_to_mega_transitions: Cell,
    pic_tag_count: Cell,
    pic_tuple_count: Cell,
};

pub const VMAssemblyFields = extern struct {
    ctx: *contexts.Context,
    spare_ctx: *contexts.Context,
    nursery: bump_allocator.BumpAllocator,
    cards_offset: Cell,
    decks_offset: Cell,
    signal_handler_addr: Cell,
    faulting_p: bool,
    _padding: [7]u8,
    special_objects: [objects.special_object_count]Cell,

    pub fn getVM(self: *VMAssemblyFields) *FactorVM {
        return @fieldParentPtr("vm_asm", self);
    }
};

pub const CToFactorFuncType = *const fn (Cell) void;

pub var g_fatal_erroring_p: bool = false;
pub const FactorVM = struct {
    vm_asm: VMAssemblyFields,
    thread: ?std.Thread.Id,
    datastack_size: Cell,
    retainstack_size: Cell,
    callstack_size: Cell,
    cards_array: ?[]u8,
    decks_array: ?[]u8,
    callback_id: i32,
    callback_ids: std.ArrayList(i32),
    c_to_factor_func: ?CToFactorFuncType,
    unused_contexts: std.ArrayList(*contexts.Context),
    active_contexts: std.ArrayListUnmanaged(*contexts.Context),
    sampling_profiler_p: bool,
    samples_per_second: Fixnum,
    profiling_samples: std.ArrayList(safepoints.SampleRecord),
    signal_resumable: bool,
    signal_number: Cell,
    signal_fault_addr: Cell,
    signal_fault_pc: Cell,
    signal_fpu_status: u32,
    signal_pipe_input: i32,
    signal_pipe_output: i32,
    gc_off: bool,
    data: ?*DataHeap,
    code: ?*CodeHeap,
    callbacks: ?*CallbackHeap,
    current_gc: ?*GCState,
    current_gc_p: bool,
    current_jit_count: Fixnum,
    gc_events: ?*std.ArrayList(GCEvent),
    gc: ?*gc.GarbageCollector,
    data_roots: DataRootStack,
    code_roots: std.ArrayList(*CodeRoot),
    fep_p: bool,
    fep_help_was_shown: bool,
    fep_disabled: bool,
    full_output: bool,
    dispatch_stats: DispatchStatistics,
    max_pic_size: Cell,
    object_counter: Cell,
    last_nano_count: u64,
    signal_callstack_seg: ?segments.Segment,
    stop_on_ctrl_break: bool,
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) !*Self {
        const vm = try allocator.create(Self);
        errdefer allocator.destroy(vm);

        vm.* = Self{
            .vm_asm = VMAssemblyFields{
                .ctx = undefined,
                .spare_ctx = undefined,
                .nursery = bump_allocator.BumpAllocator{
                    .here = 0,
                    .start = 0,
                    .end = 0,
                    .size = 0,
                },
                .cards_offset = 0,
                .decks_offset = 0,
                .signal_handler_addr = 0,
                .faulting_p = false,
                ._padding = [_]u8{0} ** 7,
                .special_objects = [_]Cell{layouts.false_object} ** objects.special_object_count,
            },
            .thread = null,
            .datastack_size = 32 * @sizeOf(Cell) * 1024,
            .retainstack_size = 32 * @sizeOf(Cell) * 1024,
            .callstack_size = 128 * @sizeOf(Cell) * 1024,
            .cards_array = null,
            .decks_array = null,
            .callback_id = 0,
            .callback_ids = .empty,
            .c_to_factor_func = null,
            .unused_contexts = .empty,
            .active_contexts = .empty,
            .sampling_profiler_p = false,
            .samples_per_second = 0,
            .profiling_samples = .empty,
            .signal_resumable = false,
            .signal_number = 0,
            .signal_fault_addr = 0,
            .signal_fault_pc = 0,
            .signal_fpu_status = 0,
            .signal_pipe_input = -1,
            .signal_pipe_output = -1,
            .gc_off = false,
            .data = null,
            .code = null,
            .callbacks = null,
            .current_gc = null,
            .current_gc_p = false,
            .current_jit_count = 0,
            .gc_events = null,
            .gc = null, // Initialized later when data heap is ready
            .data_roots = .empty,
            .code_roots = .empty,
            .fep_p = false,
            .fep_help_was_shown = false,
            .fep_disabled = false,
            .full_output = false,
            .dispatch_stats = DispatchStatistics{
                .megamorphic_cache_hits = 0,
                .megamorphic_cache_misses = 0,
                .pic_to_mega_transitions = 0,
                .cold_call_to_ic_transitions = 0,
                .ic_to_pic_transitions = 0,
                .pic_tag_count = 0,
                .pic_tuple_count = 0,
            },
            .max_pic_size = 16,
            .object_counter = 0,
            .last_nano_count = 0,
            .signal_callstack_seg = null,
            .stop_on_ctrl_break = false,
            .allocator = allocator,
        };

        vm.data_roots.ensureTotalCapacity(allocator, 128) catch {};

        return vm;
    }

    pub fn deinit(self: *Self) void {
        {
            var context = self.vm_asm.ctx;
            context.deinit(self.allocator);
            self.allocator.destroy(context);
        }
        {
            var context = self.vm_asm.spare_ctx;
            context.deinit(self.allocator);
            self.allocator.destroy(context);
        }
        for (self.unused_contexts.items) |c| {
            var context = c;
            context.deinit(self.allocator);
            self.allocator.destroy(context);
        }
        self.unused_contexts.deinit(self.allocator);
        self.active_contexts.deinit(self.allocator);
        if (self.gc) |gc_inst| gc_inst.deinit();
        self.profiling_samples.deinit(self.allocator);
        self.data_roots.deinit(self.allocator);
        self.code_roots.deinit(self.allocator);
        self.callback_ids.deinit(self.allocator);

        if (self.data == null) {
            if (self.cards_array) |cards| {
                self.allocator.free(cards);
            }
            if (self.decks_array) |decks| {
                self.allocator.free(decks);
            }
        }
        self.allocator.destroy(self);
    }

    fn addActiveContext(self: *Self, ctx: *contexts.Context) !void {
        if (ctx.isActive()) return;
        try self.active_contexts.append(self.allocator, ctx);
        ctx.active_index = @intCast(self.active_contexts.items.len - 1);
    }

    fn removeActiveContext(self: *Self, ctx: *contexts.Context) void {
        if (!ctx.isActive()) return;

        const idx: usize = @intCast(ctx.active_index);
        std.debug.assert(idx < self.active_contexts.items.len);
        std.debug.assert(self.active_contexts.items[idx] == ctx);

        const last_index = self.active_contexts.items.len - 1;
        if (idx != last_index) {
            const moved = self.active_contexts.items[last_index];
            self.active_contexts.items[idx] = moved;
            moved.active_index = @intCast(idx);
        }
        _ = self.active_contexts.pop();

        ctx.active_index = std.math.maxInt(u32);
    }

    pub fn clearActiveContexts(self: *Self) void {
        for (self.active_contexts.items) |ctx| {
            ctx.active_index = std.math.maxInt(u32);
        }
        self.active_contexts.clearRetainingCapacity();
    }

    pub fn newContext(self: *Self) !*contexts.Context {
        var new_ctx: *contexts.Context = undefined;

        if (self.unused_contexts.items.len > 0) {
            const reused_ctx = self.unused_contexts.pop().?;
            reused_ctx.reset();
            new_ctx = reused_ctx;
        } else {
            const ctx_ptr = try self.allocator.create(contexts.Context);
            ctx_ptr.* = try contexts.Context.init(
                self.allocator,
                self.datastack_size,
                self.retainstack_size,
                self.callstack_size,
            );
            new_ctx = ctx_ptr;
        }

        try self.addActiveContext(new_ctx);

        return new_ctx;
    }

    pub fn deleteContext(self: *Self) void {
        const current = self.vm_asm.ctx;
        self.removeActiveContext(current);
        self.unused_contexts.append(self.allocator, current) catch {
            var c = current;
            c.deinit(self.allocator);
            self.allocator.destroy(c);
            return;
        };
        while (self.unused_contexts.items.len > 10) {
            var c = self.unused_contexts.orderedRemove(0);
            c.deinit(self.allocator);
            self.allocator.destroy(c);
        }
    }

    inline fn writeBarrierSlot(self: *Self, slot_addr: Cell) void {
        const card_ptr: *u8 = @ptrFromInt(self.vm_asm.cards_offset +% (slot_addr >> @intCast(card_bits)));
        card_ptr.* = card_mark_mask;
        const deck_ptr: *u8 = @ptrFromInt(self.vm_asm.decks_offset +% (slot_addr >> @intCast(deck_bits)));
        deck_ptr.* = card_mark_mask;
    }

    pub fn writeBarrierKnownHeap(self: *Self, slot_ptr: *Cell) void {
        self.writeBarrierSlot(@intFromPtr(slot_ptr));
    }

    pub fn writeBarrierKnownHeapWithValue(self: *Self, slot_ptr: *Cell, value: Cell) void {
        if (layouts.isImmediate(value)) return;

        const slot_addr = @intFromPtr(slot_ptr);
        const nursery = self.vm_asm.nursery;
        if (slot_addr >= nursery.start and slot_addr < nursery.end) return;

        const value_addr = layouts.UNTAG(value);
        if (value_addr >= nursery.start and value_addr < nursery.end) {
            self.writeBarrierSlot(slot_addr);
            return;
        }

        const data_ptr = self.data orelse return;
        const heap: *DataHeap = @ptrCast(@alignCast(data_ptr));

        if (slot_addr >= heap.tenured.start and slot_addr < heap.tenured.end and
            value_addr >= heap.aging.start and value_addr < heap.aging.end)
        {
            self.writeBarrierSlot(slot_addr);
        }
    }

    pub fn writeBarrier(self: *Self, slot_ptr: *Cell) void {
        const slot_addr = @intFromPtr(slot_ptr);
        if (self.data) |data_ptr| {
            const heap: *DataHeap = @ptrCast(@alignCast(data_ptr));
            if (slot_addr < heap.segment.start or slot_addr >= heap.segment.end) {
                return;
            }
        }
        self.writeBarrierSlot(slot_addr);
    }

    pub fn writeBarrierWithValue(self: *Self, slot_ptr: *Cell, value: Cell) void {
        if (layouts.isImmediate(value)) return;

        const slot_addr = @intFromPtr(slot_ptr);
        if (self.data) |data_ptr| {
            const heap: *DataHeap = @ptrCast(@alignCast(data_ptr));
            if (slot_addr < heap.segment.start or slot_addr >= heap.segment.end) {
                return;
            }
        }
        self.writeBarrierSlot(slot_addr);
    }

    pub fn writeBarrierRange(self: *Self, addr: Cell, size: Cell) void {
        if (size == 0) return;

        const data_ptr = self.data orelse return;
        const heap: *DataHeap = @ptrCast(@alignCast(data_ptr));
        if (addr < heap.segment.start or addr >= heap.segment.end) {
            return;
        }
        const raw_end = addr +% size;
        const unclamped_end = if (raw_end < addr) heap.segment.end else raw_end;
        const range_end = @min(unclamped_end, heap.segment.end);
        if (range_end <= addr) return;
        const first_card_abs = addr >> @intCast(card_bits);
        const last_card_abs = (range_end - 1) >> @intCast(card_bits);
        const card_base = heap.segment.start >> @intCast(card_bits);
        const first_deck_abs = addr >> @intCast(deck_bits);
        const last_deck_abs = (range_end - 1) >> @intCast(deck_bits);
        const deck_base = heap.segment.start >> @intCast(deck_bits);
        std.debug.assert(first_card_abs >= card_base);
        std.debug.assert(last_card_abs >= first_card_abs);
        const card_len: Cell = @intCast(heap.cards.cards.len);
        const deck_len: Cell = @intCast(heap.decks.decks.len);
        std.debug.assert(first_card_abs < card_base + card_len);
        std.debug.assert(last_card_abs < card_base + card_len);
        std.debug.assert(first_deck_abs < deck_base + deck_len);
        std.debug.assert(last_deck_abs < deck_base + deck_len);
        const card_count = last_card_abs - first_card_abs + 1;
        const first_card: usize = @intCast(first_card_abs - card_base);
        @memset(heap.cards.cards[first_card..][0..@intCast(card_count)], card_mark_mask);
        std.debug.assert(first_deck_abs >= deck_base);
        std.debug.assert(last_deck_abs >= first_deck_abs);
        const deck_count = last_deck_abs - first_deck_abs + 1;
        const first_deck: usize = @intCast(first_deck_abs - deck_base);
        @memset(heap.decks.decks[first_deck..][0..@intCast(deck_count)], card_mark_mask);
    }

    pub fn markAllCards(self: *Self) void {
        if (self.cards_array) |cards| {
            @memset(cards, 0xff);
        }
        if (self.decks_array) |decks| {
            @memset(decks, 0xff);
        }
    }

    pub fn syncContextFromRegisters(_: *Self) void {
    }

    pub fn specialObject(self: *const Self, index: objects.SpecialObject) Cell {
        return self.vm_asm.special_objects[@intFromEnum(index)];
    }

    pub fn setSpecialObject(self: *Self, index: objects.SpecialObject, value: Cell) void {
        self.vm_asm.special_objects[@intFromEnum(index)] = value;
    }

    pub fn tagBoolean(self: *const Self, untagged: bool) Cell {
        return if (untagged) self.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.canonical_true)] else layouts.false_object;
    }

    pub fn checkTag(self: *Self, cell: Cell, expected: layouts.TypeTag) void {
        if (!layouts.hasTag(cell, expected)) {
            self.typeError(expected, cell);
        }
    }

    pub fn generalError(self: *Self, error_type: @import("signals.zig").VMError, arg1: Cell, arg2: Cell) noreturn {
        @import("signals.zig").generalError(self, error_type, arg1, arg2);
    }

    pub fn typeError(self: *Self, expected_type: layouts.TypeTag, actual: Cell) noreturn {
        self.generalError(.type_error, layouts.tagFixnum(@intFromEnum(expected_type)), actual);
    }

    pub fn memoryError(self: *Self) noreturn {
        self.generalError(.memory, 0, 0);
    }

    pub fn ioError(self: *Self, errno_val: layouts.Fixnum) noreturn {
        self.generalError(.io, layouts.tagFixnum(@intCast(errno_val)), layouts.false_object);
    }

    pub fn divideByZeroError(self: *Self) noreturn {
        self.generalError(.divide_by_zero, layouts.false_object, layouts.false_object);
    }

    pub fn expiredError(self: *Self, obj: Cell) noreturn {
        self.generalError(.expired, obj, layouts.false_object);
    }

    pub fn fixnumRangeError(self: *Self, obj: Cell) noreturn {
        self.generalError(.out_of_fixnum_range, obj, layouts.false_object);
    }

    pub fn alienOffset(self: *Self, obj: Cell) ?[*]u8 {
        if (obj == layouts.false_object) {
            return null;
        }

        switch (layouts.typeTag(obj)) {
            .byte_array => {
                const ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(obj));
                return ba.data();
            },
            .alien => {
                const alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(obj));
                return @ptrFromInt(alien.address);
            },
            else => self.typeError(.alien, obj),
        }
    }

    pub fn getContextFromAlien(self: *Self, alien_cell: Cell) ?*contexts.Context {
        if (alien_cell == layouts.false_object) return null;
        self.checkTag(alien_cell, .alien);
        const alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(alien_cell));
        if (alien.base != layouts.false_object) {
            self.typeError(.alien, alien_cell);
        }
        return @ptrFromInt(alien.address);
    }

    pub fn getCtx(self: *Self) *contexts.Context {
        return self.vm_asm.ctx;
    }

    pub fn setCtx(self: *Self, c: *contexts.Context) void {
        self.vm_asm.ctx = c;
    }

    pub fn getNursery(self: *Self) *bump_allocator.BumpAllocator {
        return &self.vm_asm.nursery;
    }

    pub fn getSpecialObjects(self: *Self) *[objects.special_object_count]Cell {
        return &self.vm_asm.special_objects;
    }

    pub fn peek(self: *const Self) Cell {
        return self.vm_asm.ctx.peek();
    }

    pub fn pop(self: *Self) Cell {
        return self.vm_asm.ctx.pop();
    }

    pub fn push(self: *Self, value: Cell) void {
        self.vm_asm.ctx.push(value);
    }

    pub fn replace(self: *Self, value: Cell) void {
        self.vm_asm.ctx.replace(value);
    }

    pub fn cToFactor(self: *Self, quot: Cell) void {
        if (self.c_to_factor_func == null) {
            self.initCToFactorFunc();
        }

        if (self.c_to_factor_func) |func| {
            if (builtin.cpu.arch == .aarch64 and (builtin.os.tag == .macos or builtin.os.tag == .ios)) {
                const pthread_jit_write_protect_np = struct {
                    extern "c" fn pthread_jit_write_protect_np(enabled: c_int) void;
                }.pthread_jit_write_protect_np;
                pthread_jit_write_protect_np(1); // Enable write protection (allow execution)
            }

            const func_addr = @intFromPtr(func);
            const quot_val = quot;

            if (builtin.cpu.arch == .x86_64) {
                asm volatile (
                    \\mov %[quot], %%rdi
                    \\call *%[func]
                    :
                    : [quot] "r" (quot_val),
                      [func] "r" (func_addr),
                    : .{ .rax = true, .rcx = true, .rdx = true, .rsi = true, .rdi = true, .r8 = true, .r9 = true, .r10 = true, .r11 = true, .memory = true, .cc = true });
            } else if (builtin.cpu.arch == .aarch64) {
                asm volatile (
                    \\mov x0, %[quot]
                    \\blr %[func]
                    :
                    : [quot] "r" (quot_val),
                      [func] "r" (func_addr),
                    : .{ .x0 = true, .x1 = true, .x2 = true, .x3 = true, .x4 = true, .x5 = true, .x6 = true, .x7 = true, .x8 = true, .x9 = true, .x10 = true, .x11 = true, .x12 = true, .x13 = true, .x14 = true, .x15 = true, .x16 = true, .x17 = true, .x30 = true, .memory = true });
            } else {
                @compileError("Unsupported architecture for callback");
            }
        }
    }

    fn initCToFactorFunc(self: *Self) void {
        const c_to_factor_word = self.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.c_to_factor_word)];
        if (c_to_factor_word == layouts.false_object) return;

        if (self.callbacks == null) {
            const callback_size = 256 * 1024; // 256KB default
            const heap_ptr = self.allocator.create(CallbackHeap) catch @panic("OOM: callback heap");
            heap_ptr.* = CallbackHeap.init(self.allocator, callback_size) catch {
                self.allocator.destroy(heap_ptr);
                return;
            };
            self.callbacks = heap_ptr;
        }

        const vm_ptr = @intFromPtr(&self.vm_asm);

        const c_to_factor_block = self.callbacks.?.add(
            c_to_factor_word,
            0, // return_rewind = 0 for c_to_factor
            vm_ptr,
            self,
        );

        if (c_to_factor_block) |block| {
            self.c_to_factor_func = @ptrFromInt(block.entryPoint());
        }
    }

    pub fn beginCallback(self: *Self, quot: Cell) Cell {
        self.vm_asm.ctx.reset();
        self.vm_asm.spare_ctx = self.newContext() catch @panic("OOM");

        self.callback_ids.append(self.allocator, self.callback_id) catch @panic("OOM");
        self.callback_id += 1;

        self.initContext(self.vm_asm.ctx);

        return quot;
    }

    pub fn endCallback(self: *Self) void {
        if (self.callback_ids.items.len > 0) {
            _ = self.callback_ids.pop();
        }

        self.deleteContext();
    }

    pub fn initContext(self: *Self, ctx: *contexts.Context) void {
        const ctx_alien = self.allotAlien(layouts.false_object, @intFromPtr(ctx));
        ctx.context_objects[2] = ctx_alien;
    }

    pub fn allotUninitializedArray(self: *Self, capacity: Cell) ?Cell {
        const size = layouts.arraySize(layouts.Array, capacity);

        const tagged = self.allotObject(.array, size) orelse return null;
        const addr = layouts.UNTAG(tagged);
        const array: *layouts.Array = @ptrFromInt(addr);
        array.capacity = layouts.tagFixnum(@as(Fixnum, @intCast(capacity)));
        return tagged;
    }

    pub fn allotArray(self: *Self, capacity: Cell, fill: Cell) ?Cell {
        var rooted_fill = fill;
        const needs_root = !layouts.isImmediate(rooted_fill);
        if (needs_root) {
            self.data_roots.appendAssumeCapacity(&rooted_fill);
        }
        defer if (needs_root) {
            _ = self.data_roots.pop();
        };

        const tagged = self.allotUninitializedArray(capacity) orelse return null;
        const array: *layouts.Array = @ptrFromInt(layouts.UNTAG(tagged));

        const cap: usize = @intCast(capacity);
        if (cap > 0) {
            @memset(array.data()[0..cap], rooted_fill);
        }
        return tagged;
    }

    pub fn reallotArray(self: *Self, old_array_: Cell, new_capacity: Cell) ?Cell {
        std.debug.assert(layouts.hasTag(old_array_, .array));

        var old_array = old_array_;
        self.data_roots.appendAssumeCapacity(&old_array);
        defer _ = self.data_roots.pop();

        const old_arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(old_array));
        const old_capacity = old_arr.getCapacity();

        if (old_capacity == new_capacity) {
            return old_array;
        }

        const in_nursery = self.vm_asm.nursery.contains(@ptrFromInt(layouts.UNTAG(old_array)));
        if (in_nursery and new_capacity <= old_capacity) {
            const old_arr_mut: *layouts.Array = @ptrFromInt(layouts.UNTAG(old_array));
            old_arr_mut.capacity = layouts.tagFixnum(@as(Fixnum, @intCast(new_capacity)));
            return old_array;
        }

        const new_array = self.allotUninitializedArray(new_capacity) orelse return null;
        const new_arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(new_array));

        const old_arr_after_gc: *layouts.Array = @ptrFromInt(layouts.UNTAG(old_array));

        const to_copy = @min(old_capacity, new_capacity);
        const old_data = old_arr_after_gc.data();
        const new_data = new_arr.data();

        @memcpy(new_data[0..to_copy], old_data[0..to_copy]);

        if (new_capacity > to_copy) {
            @memset(new_data[to_copy..new_capacity], layouts.false_object);
        }

        return new_array;
    }

    pub fn allotByteArray(self: *Self, size: usize) Cell {
        const tagged = self.allotUninitializedByteArray(size);
        const ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(tagged));
        @memset(ba.data()[0..size], 0);
        return tagged;
    }

    pub fn allotUninitializedByteArray(self: *Self, size: usize) Cell {
        const header_size = @sizeOf(layouts.ByteArray);
        const total_size = layouts.alignCell(header_size + size, layouts.data_alignment);

        const tagged = self.allotObject(.byte_array, total_size) orelse {
            self.memoryError();
        };
        const addr = layouts.UNTAG(tagged);
        const ba: *layouts.ByteArray = @ptrFromInt(addr);
        ba.capacity = layouts.tagFixnum(@as(Fixnum, @intCast(size)));

        return tagged;
    }

    pub fn allotAlien(self: *Self, base: Cell, displacement: Cell) Cell {
        const tagged = self.allotObject(.alien, @sizeOf(layouts.Alien)) orelse {
            self.memoryError();
        };
        const alien: *layouts.Alien = @ptrFromInt(layouts.UNTAG(tagged));

        alien.base = base;
        alien.expired = layouts.false_object;
        alien.displacement = displacement;

        if (base == layouts.false_object) {
            alien.address = displacement;
        } else {
            alien.address = layouts.UNTAG(base) + @sizeOf(layouts.ByteArray) + displacement;
        }

        return tagged;
    }

    pub fn allotBignumFromCell(self: *Self, value: Cell) Cell {
        const bignum_mod = @import("bignum.zig");
        const num_digits: Cell = bignum_mod.countDigitsUnsigned(value);
        const bn = bignum_mod.allocBignum(self, num_digits, false) catch {
            self.memoryError();
        };
        var val = value;
        var i: Cell = 0;
        while (val != 0) : (i += 1) {
            bn.setDigit(i, val & bignum_mod.DIGIT_MASK);
            val >>= bignum_mod.DIGIT_BITS;
        }

        return layouts.tagBignum(bn);
    }

    pub fn allotBignumFromSignedCell(self: *Self, value: i64) Cell {
        const bignum_mod = @import("bignum.zig");
        const abs_value: Cell = @bitCast(if (value == std.math.minInt(i64)) value else -value);
        const num_digits: Cell = bignum_mod.countDigitsUnsigned(abs_value);
        const bn = bignum_mod.allocBignum(self, num_digits, true) catch {
            self.memoryError();
        };
        var val = abs_value;
        var i: Cell = 0;
        while (val != 0) : (i += 1) {
            bn.setDigit(i, val & bignum_mod.DIGIT_MASK);
            val >>= bignum_mod.DIGIT_BITS;
        }

        return layouts.tagBignum(bn);
    }


    pub fn allotLargeObject(self: *Self, type_tag: layouts.TypeTag, size: Cell) ?Cell {
        const data_heap_mod = @import("data_heap.zig");
        const data_ptr = self.data orelse @panic("data heap not initialized");

        var heap: *data_heap_mod.DataHeap = @ptrCast(@alignCast(data_ptr));

        var required_free = size + heap.highWaterMark();
        if (!heap.tenured.free_list.canAllot(required_free)) {
            if (self.gc) |gc_instance| {
                gc_instance.gc(.collect_compact) catch @panic("GC compact failed during large object allocation");
            }
        }

        heap = @ptrCast(@alignCast(self.data orelse @panic("data heap lost after compaction")));
        required_free = size + heap.highWaterMark();
        if (!heap.tenured.free_list.canAllot(required_free)) {
            if (self.gc) |gc_instance| {
                gc_instance.collectGrowingDataHeap(size) catch @panic("GC grow failed during large object allocation");
            }
        }

        heap = @ptrCast(@alignCast(self.data orelse @panic("data heap lost after growing")));
        const addr = heap.allocateTenured(size) orelse @panic("Out of memory in allot_large_object (tenured)");

        if (!layouts.typeHasNoPointers(type_tag)) {
            self.writeBarrierRange(addr, size);
        }

        const obj_ptr: *layouts.Object = @ptrFromInt(addr);
        obj_ptr.header = @as(Cell, @intFromEnum(type_tag)) << 2;

        return addr | @intFromEnum(type_tag);
    }

    pub fn allotObject(self: *Self, type_tag: layouts.TypeTag, size: Cell) ?Cell {
        std.debug.assert(!self.current_gc_p);

        const aligned_size = layouts.alignCell(size, layouts.data_alignment);

        const addr = self.vm_asm.nursery.here;
        const new_here = addr + aligned_size;
        if (new_here <= self.vm_asm.nursery.end) {
            self.vm_asm.nursery.here = new_here;
            const obj_ptr: *layouts.Object = @ptrFromInt(addr);
            obj_ptr.header = @as(Cell, @intFromEnum(type_tag)) << 2;
            return addr | @intFromEnum(type_tag);
        }

        return self.allotObjectSlow(type_tag, size, aligned_size);
    }

    noinline fn allotObjectSlow(self: *Self, type_tag: layouts.TypeTag, size: Cell, aligned_size: Cell) ?Cell {
        if (aligned_size >= self.vm_asm.nursery.size) {
            return self.allotLargeObject(type_tag, size);
        }

        self.minorGc();

        const addr = self.vm_asm.nursery.here;
        const new_here = addr + aligned_size;
        if (new_here <= self.vm_asm.nursery.end) {
            self.vm_asm.nursery.here = new_here;
            const obj_ptr: *layouts.Object = @ptrFromInt(addr);
            obj_ptr.header = @as(Cell, @intFromEnum(type_tag)) << 2;
            return addr | @intFromEnum(type_tag);
        }
        return null;
    }

    pub fn allotCodeBlock(self: *Self, size: Cell) *code_blocks_mod.CodeBlock {
        const code_heap = self.code orelse @panic("code heap not initialized");

        if (code_heap.allocate(size)) |block| {
            code_heap.writeBarrier(block) catch {};
            return block;
        }

        if (self.gc) |gc_instance| {
            self.current_gc_p = true;
            defer self.current_gc_p = false;
            gc_instance.collect(.collect_compact);
        }

        const code_heap2 = self.code orelse @panic("code heap lost after compaction");
        if (code_heap2.allocate(size)) |block| {
            code_heap2.writeBarrier(block) catch {};
            return block;
        }

        @panic("Out of memory in allot_code_block");
    }


    pub fn setDataHeap(self: *Self, heap: *DataHeap) void {
        self.data = heap;

        self.vm_asm.nursery = heap.nursery;

        const data_start = heap.segment.start;
        const cards_ptr = @intFromPtr(heap.cards.cards.ptr);
        const decks_ptr = @intFromPtr(heap.decks.decks.ptr);
        self.vm_asm.cards_offset = cards_ptr -% (data_start >> card_bits);
        self.vm_asm.decks_offset = decks_ptr -% (data_start >> deck_bits);

        self.cards_array = heap.cards.cards;
        self.decks_array = heap.decks.decks;
    }

    pub fn minorGc(self: *Self) void {
        if (self.gc_off) return;

        if (self.gc) |gc_instance| {
            self.current_gc_p = true;
            defer self.current_gc_p = false;
            gc_instance.gc(.collect_nursery) catch {
                gc_instance.collectFull(true);
            };
        }
    }

    pub fn fullGc(self: *Self) void {
        if (self.gc) |gc_instance| {
            self.current_gc_p = true;
            defer self.current_gc_p = false;
            gc_instance.gc(.collect_full) catch @panic("GC failed");
        }
    }

    pub fn callstackNeedsGuardUnlock(self: *Self) bool {
        const seg = self.vm_asm.ctx.callstack_seg orelse return false;
        const top = self.vm_asm.ctx.callstack_top;
        if (top <= seg.start) return true; // already in or past guard area
        return (top - seg.start) < segments.Segment.gc_stack_headroom;
    }

    pub fn ensureNurserySpace(self: *Self, size: Cell) bool {
        if (self.vm_asm.nursery.here + size <= self.vm_asm.nursery.end) {
            return true; // Space available
        }

        self.minorGc();
        return self.vm_asm.nursery.here + size <= self.vm_asm.nursery.end;
    }


    pub fn lazyJitCompileEntryPoint(self: *const Self) Cell {
        const lazy_word = self.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.lazy_jit_compile_word)];
        if (lazy_word == layouts.false_object) return 0;
        std.debug.assert(layouts.hasTag(lazy_word, .word));
        const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(lazy_word));
        return word.entry_point;
    }

    pub fn jitCompileQuotation(self: *Self, quot_cell: Cell, relocate: bool) void {
        std.debug.assert(layouts.hasTag(quot_cell, .quotation));

        var rooted_quot = quot_cell;
        self.data_roots.appendAssumeCapacity(&rooted_quot);
        defer _ = self.data_roots.pop();

        var quot: *layouts.Quotation = @ptrFromInt(layouts.UNTAG(rooted_quot));

        if (quot.entry_point != 0 and quot.entry_point != self.lazyJitCompileEntryPoint()) {
            return;
        }

        const compiled = self.jitCompileQuotationWithOwner(rooted_quot, rooted_quot, relocate);

        quot = @ptrFromInt(layouts.UNTAG(rooted_quot));

        if (compiled) |cb| {
            quot.entry_point = cb.entryPoint();
        }
    }

    pub fn jitCompileQuotationWithOwner(self: *Self, owner_in: Cell, quot_cell_in: Cell, relocate: bool) ?*CodeBlock {
        const jit_mod = @import("jit.zig");

        var owner = owner_in;
        var quot_cell = quot_cell_in;
        self.data_roots.appendAssumeCapacity(&owner);
        defer _ = self.data_roots.pop();
        self.data_roots.appendAssumeCapacity(&quot_cell);
        defer _ = self.data_roots.pop();

        var compiler = jit_mod.QuotationJit.init(self, owner, true, relocate);
        compiler.registerRoot();
        compiler.jit.owner = owner;
        defer compiler.deinit();

        compiler.initQuotation(quot_cell);
        compiler.iterateQuotation() catch |err| {
            std.debug.print("[jitCompileQuotationWithOwner] iterateQuotation FAILED: {} owner=0x{x} quot=0x{x}\n", .{ err, owner, quot_cell });
            return null;
        };

        const frame_size = compiler.wordStackFrameSize(owner);
        const compiled = compiler.toCodeBlock(frame_size) catch |err| {
            std.debug.print("[jitCompileQuotationWithOwner] toCodeBlock FAILED: {} owner=0x{x} quot=0x{x}\n", .{ err, owner, quot_cell });
            return null;
        };

        if (relocate) {
            if (compiled) |block| {
                self.initializeCodeBlockFromMap(@ptrCast(block));
            }
        }

        return compiled;
    }

    pub fn initializeCodeBlock(self: *Self, block: *CodeBlock, literals_cell: Cell) void {
        const c_api = @import("c_api.zig");

        var ctx = code_blocks_mod.RelocationContext{
            .vm_ptr = @intFromPtr(&self.vm_asm),
            .cards_offset = self.vm_asm.cards_offset,
            .decks_offset = self.vm_asm.decks_offset,
            .megamorphic_cache_hits_ptr = @intFromPtr(&self.dispatch_stats.megamorphic_cache_hits),
            .inline_cache_miss_ptr = @intFromPtr(&c_api.inline_cache_miss),
            .safepoint_page = if (self.code) |c| c.safepoint_page else 0,
            .max_pic_size = self.max_pic_size,
            .lazy_jit_compile_ep = self.lazyJitCompileEntryPoint(),
            .literals = null,
            .parameters = null,
        };

        if (literals_cell != layouts.false_object and
            layouts.hasTag(literals_cell, .array))
        {
            ctx.literals = @ptrFromInt(layouts.UNTAG(literals_cell));
        }

        if (block.parameters != layouts.false_object and
            layouts.hasTag(block.parameters, .array))
        {
            ctx.parameters = @ptrFromInt(layouts.UNTAG(block.parameters));
        }

        code_blocks_mod.applyRelocations(block, &ctx);

        block.flushIcache();

        if (self.code) |code_heap| {
            code_heap.writeBarrier(block) catch @panic("OOM");
            code_heap.updateScanFlags(self.allocator, block);
        }
    }

    pub fn initializeCodeBlockFromMap(self: *Self, block: *code_blocks_mod.CodeBlock) void {
        const code_heap = self.code orelse return;
        const block_addr = @intFromPtr(block);
        if (code_heap.uninitialized_blocks.get(block_addr)) |literals_cell| {
            self.initializeCodeBlock(block, literals_cell);
            _ = code_heap.removeUninitializedBlock(block_addr);
        }
    }


    pub fn factorbug(self: *Self) void {
        const debugger = @import("debugger.zig");
        debugger.factorbug(self);
    }

    pub fn criticalError(self: *Self, msg: []const u8, tagged: Cell) void {
        const debugger = @import("debugger.zig");
        debugger.criticalError(self, msg, tagged);
    }
};

// Compile-time verification of critical field offsets
comptime {
    // Verify the assembly-accessed fields are at correct offsets
    const cell_size = @sizeOf(Cell);

    // VMAssemblyFields layout verification
    std.debug.assert(@offsetOf(VMAssemblyFields, "ctx") == 0 * cell_size);

    std.debug.assert(@offsetOf(VMAssemblyFields, "spare_ctx") == 1 * cell_size);

    // nursery starts at offset 2 (ctx and spare_ctx are 2 pointers)
    std.debug.assert(@offsetOf(VMAssemblyFields, "nursery") == 2 * cell_size);

    // nursery is 4 cells, so cards_offset is at offset 6
    std.debug.assert(@offsetOf(VMAssemblyFields, "cards_offset") == 6 * cell_size);

    // decks_offset at offset 7
    std.debug.assert(@offsetOf(VMAssemblyFields, "decks_offset") == 7 * cell_size);

    std.debug.assert(@offsetOf(VMAssemblyFields, "signal_handler_addr") == 8 * cell_size);

    std.debug.assert(@offsetOf(VMAssemblyFields, "faulting_p") == 9 * cell_size);

    std.debug.assert(@offsetOf(VMAssemblyFields, "special_objects") == 10 * cell_size);

    // Note: JIT code uses &vm.vm_asm as the VM pointer, not &vm
    // So offsets within VMAssemblyFields matter (verified above), but
    // the offset of vm_asm within FactorVM doesn't matter for JIT
}
