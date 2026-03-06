// vm.zig - Main Factor VM structure
// Field layout in the first section is critical for assembly compatibility
// Must be kept in sync with:
//   basis/vm/vm.factor
//   basis/compiler/constants/constants.factor

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
const mark_stack_mod = @import("mark_stack.zig");
const objects = @import("objects.zig");
const safepoints = @import("safepoints.zig");
const segments = @import("segments.zig");

const Cell = layouts.Cell;
const Fixnum = layouts.Fixnum;

// Write barrier card/deck constants
pub const card_bits: Cell = 8;
pub const card_size: Cell = 1 << card_bits; // 256 bytes
pub const deck_bits: Cell = 18;
pub const deck_size: Cell = 1 << deck_bits; // 256 KB

pub const card_mark_mask: u8 = card_points_to_nursery | card_points_to_aging;
pub const card_points_to_nursery: u8 = 0x80;
pub const card_points_to_aging: u8 = 0x40;

// Use the actual DataHeap type from data_heap module
pub const DataHeap = data_heap.DataHeap;

// CodeBlock is defined in code_blocks.zig - re-exported here for compatibility
pub const CodeBlock = code_blocks_mod.CodeBlock;

// CodeHeap is defined in code_heap.zig - re-exported here for compatibility
pub const CodeHeap = @import("code_heap.zig").CodeHeap;

// Code roots - return addresses that must be updated/invalidated across GC.
// Mirrors vm/code_roots.hpp (RAII) from C++.
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

// Use the real CallbackHeap from callbacks module
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

// GC phases that we record timing for
pub const GCPhase = enum(u32) {
    card_scan = 0,
    code_scan = 1,
    data_sweep = 2,
    code_sweep = 3,
    data_compaction = 4,
    marking = 5,
};

/// Layout must match C++ data_heap_room and Factor data-heap-room STRUCT.
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

/// Layout must match C++ allocator_room and Factor mark-sweep-sizes STRUCT.
pub const AllocatorRoom = extern struct {
    size: Cell,
    occupied_space: Cell,
    total_free: Cell,
    contiguous_free: Cell,
    free_block_count: Cell,
};

/// Layout must match C++ gc_event and Factor gc-event STRUCT (vm/gc.hpp).
/// C++ size: 4 (op) + 4 (pad) + 112 + 40 + 112 + 40 + 24 + 8 + 8 + 48 + 8 = 408 bytes
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
    const gc_instance = vm.garbage_collector orelse return std.mem.zeroes(DataHeapRoom);
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
        .mark_stack = vm.mark_stack.capacity() * @sizeOf(Cell),
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
/// Layout must match C++ dispatch_statistics and Factor dispatch-statistics STRUCT.
pub const DispatchStatistics = extern struct {
    megamorphic_cache_hits: Cell,
    megamorphic_cache_misses: Cell,
    cold_call_to_ic_transitions: Cell,
    ic_to_pic_transitions: Cell,
    pic_to_mega_transitions: Cell,
    pic_tag_count: Cell,
    pic_tuple_count: Cell,
};

// Assembly-accessible portion of VM - exact layout required
// This must match the C++ factor_vm struct's first fields exactly
pub const VMAssemblyFields = extern struct {
    // Current context (offset 0)
    ctx: *contexts.Context,

    // Spare context -- for callbacks (offset 1)
    spare_ctx: *contexts.Context,

    // Nursery allocator - new objects are allocated here (offset 2-5)
    // Note: this is embedded, not a pointer, for assembly access
    nursery: bump_allocator.BumpAllocator,

    // Add this to a shifted address to compute write barrier offsets (offset 6)
    cards_offset: Cell,

    // Write barrier deck offset (offset 7)
    decks_offset: Cell,

    // cdecl signal handler address, used by signal handler subprimitives (offset 8)
    signal_handler_addr: Cell,

    // are we handling a memory error? used to detect double faults (offset 9)
    faulting_p: bool,

    // Padding to align special_objects to offset 10
    _padding: [7]u8,

    // Various special objects (offset 10 in bootstrap cells)
    special_objects: [objects.special_object_count]Cell,

    pub inline fn getVM(self: *VMAssemblyFields) *FactorVM {
        return @fieldParentPtr("vm_asm", self);
    }
};

// C-to-Factor function type - takes quotation cell as argument
pub const CToFactorFuncType = *const fn (Cell) void;

// Global fatal error flag (was pub var in struct, moved out for layout consistency)
pub var g_fatal_erroring_p: bool = false;

// Main Factor VM structure
pub const FactorVM = struct {
    // Assembly-accessible fields - MUST be first (at offset 0)
    // Using align(1) to prevent padding before this field
    vm_asm: VMAssemblyFields,

    // Handle to the main thread we run in
    thread: ?std.Thread.Id,

    // Data stack and retain stack sizes
    datastack_size: Cell,
    retainstack_size: Cell,
    callstack_size: Cell,

    // GC write barrier tracking arrays (allocated for heap lifetime)
    cards_array: ?[]u8,
    decks_array: ?[]u8,
    // Next callback ID
    callback_id: i32,

    // Callback IDs stack for tracking nested callbacks
    callback_ids: std.ArrayList(i32),

    // c_to_factor function pointer - lazily initialized
    c_to_factor_func: ?CToFactorFuncType,

    // Pooling unused contexts
    unused_contexts: std.ArrayList(*contexts.Context),

    // Active contexts for GC tracing
    active_contexts: std.ArrayListUnmanaged(*contexts.Context),

    // Is profiling enabled?
    sampling_profiler_p: bool,
    samples_per_second: Fixnum,
    profiling_samples: std.ArrayList(safepoints.SampleRecord),

    // Global variables used to pass fault handler state from signal handler to VM
    signal_resumable: bool,
    signal_number: Cell,
    signal_fault_addr: Cell,
    signal_fault_pc: Cell,
    signal_fpu_status: u32,

    // Pipe used to notify Factor multiplexer of signals
    signal_pipe_input: i32,
    signal_pipe_output: i32,

    // GC is off during heap walking
    gc_off: bool,

    // Data heap
    data: ?*DataHeap,

    // Code heap
    code: ?*CodeHeap,

    // Pinned callback stubs
    callbacks: ?*CallbackHeap,

    // Only set if we're performing a GC
    current_gc: ?*GCState,
    current_gc_p: bool,

    // Set if we're in the jit
    current_jit_count: Fixnum,

    // Mark stack used for mark & sweep GC
    mark_stack: mark_stack_mod.MarkStack,

    // GC events
    gc_events: ?*std.ArrayList(GCEvent),

    // Garbage collector instance
    garbage_collector: ?*gc.GarbageCollector,

    // Data roots for GC.
    data_roots: DataRootStack,
    // Code roots for GC (return addresses that must be updated/invalidated)
    code_roots: std.ArrayList(*CodeRoot),

    // Debugger
    fep_p: bool,
    fep_help_was_shown: bool,
    fep_disabled: bool,
    full_output: bool,

    // Method dispatch statistics
    dispatch_stats: DispatchStatistics,

    // Number of entries in a polymorphic inline cache
    max_pic_size: Cell,

    // Incrementing object counter for identity hashing
    object_counter: Cell,

    // Sanity check to ensure that monotonic counter doesn't decrease
    last_nano_count: u64,

    // Stack for signal handlers (Unix only)
    signal_callstack_seg: ?segments.Segment,

    // Allow Ctrl-Break in busy loop (Windows only)
    stop_on_ctrl_break: bool,

    // Allocator for internal data structures
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
            .datastack_size = 32 * @sizeOf(Cell) * 1024, // 256KB (matches C++ default: 32 * sizeof(cell) kilobytes)
            .retainstack_size = 32 * @sizeOf(Cell) * 1024, // 256KB (matches C++ default)
            .callstack_size = 128 * @sizeOf(Cell) * 1024, // 1MB (matches C++ default: 128 * sizeof(cell) kilobytes)
            .cards_array = null,
            .decks_array = null,
            .callback_id = 0,
            .callback_ids = .{},
            .c_to_factor_func = null,
            .unused_contexts = .{},
            .active_contexts = .{},
            .sampling_profiler_p = false,
            .samples_per_second = 0,
            .profiling_samples = .{},
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
            .mark_stack = mark_stack_mod.MarkStack.init(allocator),
            .gc_events = null,
            .garbage_collector = null, // Initialized later when data heap is ready
            .data_roots = .{},
            .code_roots = .{},
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
            .max_pic_size = 3,
            .object_counter = 0,
            .last_nano_count = 0,
            .signal_callstack_seg = null,
            .stop_on_ctrl_break = false,
            .allocator = allocator,
        };

        return vm;
    }

    pub fn deinit(self: *Self) void {
        // Clean up contexts
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
        self.mark_stack.deinit();
        self.profiling_samples.deinit(self.allocator);
        self.data_roots.deinit(self.allocator);
        self.code_roots.deinit(self.allocator);
        self.callback_ids.deinit(self.allocator);

        // Clean up GC write barrier tracking arrays.
        // If a data heap is attached, it owns these arrays.
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

    // Create a new context
    // Matches C++ VM: new_context() in contexts.cpp
    pub fn newContext(self: *Self) !*contexts.Context {
        var new_ctx: *contexts.Context = undefined;

        // Try to reuse an unused context
        if (self.unused_contexts.items.len > 0) {
            const reused_ctx = self.unused_contexts.pop().?;
            reused_ctx.reset();
            new_ctx = reused_ctx;
        } else {
            // Allocate new context segments.
            const ctx_ptr = try self.allocator.create(contexts.Context);
            ctx_ptr.* = try contexts.Context.init(
                self.allocator,
                self.datastack_size,
                self.retainstack_size,
                self.callstack_size,
            );
            new_ctx = ctx_ptr;
        }

        // Add to active contexts list.
        try self.addActiveContext(new_ctx);

        return new_ctx;
    }

    // Delete the current context - moves it to unused pool
    // Matches C++ VM: delete_context() in contexts.cpp
    // NOTE: This does NOT switch contexts (ctx = spare_ctx). The context switch
    // is handled by the callback stub's epilogue which restores the saved ctx.
    pub fn deleteContext(self: *Self) void {
        const current = self.vm_asm.ctx;
        self.removeActiveContext(current);
        self.unused_contexts.append(self.allocator, current) catch {
            var c = current;
            c.deinit(self.allocator);
            self.allocator.destroy(c);
            return;
        };

        // Limit unused context pool size to 10 (matches C++ VM).
        // Remove from front (oldest), matching C++ front()/pop_front() FIFO order.
        // Using pop() (LIFO) would destroy the just-added context while vm_asm.ctx
        // still references it — a use-after-free that causes NULL derefs in fib6.
        while (self.unused_contexts.items.len > 10) {
            var c = self.unused_contexts.orderedRemove(0);
            c.deinit(self.allocator);
            self.allocator.destroy(c);
        }
    }

    // Fast write barrier for slots known to be inside the main data heap segment.
    pub inline fn writeBarrierKnownHeap(self: *Self, slot_ptr: *Cell) void {
        const slot_addr = @intFromPtr(slot_ptr);
        const card_ptr: *u8 = @ptrFromInt(self.vm_asm.cards_offset + (slot_addr >> card_bits));
        card_ptr.* = card_mark_mask;
        const deck_ptr: *u8 = @ptrFromInt(self.vm_asm.decks_offset + (slot_addr >> deck_bits));
        deck_ptr.* = card_mark_mask;
    }

    // Value-aware fast write barrier for known-heap slots.
    // Skip marking when storing immediates since they cannot reference young objects.
    pub inline fn writeBarrierKnownHeapWithValue(self: *Self, slot_ptr: *Cell, value: Cell) void {
        if (layouts.isImmediate(value)) return;
        self.writeBarrierKnownHeap(slot_ptr);
    }

    // Write barrier - must be called when storing a pointer from older to younger generation
    pub inline fn writeBarrier(self: *Self, slot_ptr: *Cell) void {
        // Guard against slots outside the main data heap segment.
        const slot_addr = @intFromPtr(slot_ptr);
        if (self.data) |data_ptr| {
            const heap: *DataHeap = @ptrCast(@alignCast(data_ptr));
            if (slot_addr < heap.segment.start or slot_addr >= heap.segment.end) {
                return;
            }
        }
        self.writeBarrierKnownHeap(slot_ptr);
    }

    // Value-aware write barrier.
    // Prefer this in hot store paths where the stored value is already available.
    pub inline fn writeBarrierWithValue(self: *Self, slot_ptr: *Cell, value: Cell) void {
        if (layouts.isImmediate(value)) return;

        const slot_addr = @intFromPtr(slot_ptr);
        if (self.data) |data_ptr| {
            const heap: *DataHeap = @ptrCast(@alignCast(data_ptr));
            if (slot_addr < heap.segment.start or slot_addr >= heap.segment.end) {
                return;
            }
        }
        self.writeBarrierKnownHeap(slot_ptr);
    }

    // Write barrier for a range - marks all cards covering the object
    // Used when allocating large objects in tenured space
    pub fn writeBarrierRange(self: *Self, addr: Cell, size: Cell) void {
        if (size == 0) return;

        const data_ptr = self.data orelse return;
        const heap: *DataHeap = @ptrCast(@alignCast(data_ptr));
        if (addr < heap.segment.start or addr >= heap.segment.end) {
            return;
        }

        // Clamp end to heap bounds, handling arithmetic overflow.
        const raw_end = addr +% size;
        const unclamped_end = if (raw_end < addr) heap.segment.end else raw_end;
        const range_end = @min(unclamped_end, heap.segment.end);
        if (range_end <= addr) return;

        // Mark cards in one bulk memset using absolute-index addressing to
        // match the JIT write barrier formula (cards_offset + (addr >> card_bits)).
        const first_card_abs = addr >> @intCast(card_bits);
        const last_card_abs = (range_end - 1) >> @intCast(card_bits);
        const card_count = last_card_abs - first_card_abs + 1;
        const cards_ptr: [*]u8 = @ptrFromInt(self.vm_asm.cards_offset +% first_card_abs);
        @memset(cards_ptr[0..card_count], card_mark_mask);

        // Mark decks similarly.
        const first_deck_abs = addr >> @intCast(deck_bits);
        const last_deck_abs = (range_end - 1) >> @intCast(deck_bits);
        const deck_count = last_deck_abs - first_deck_abs + 1;
        const decks_ptr: [*]u8 = @ptrFromInt(self.vm_asm.decks_offset +% first_deck_abs);
        @memset(decks_ptr[0..deck_count], card_mark_mask);
    }

    // Mark all cards and decks as dirty (used by become).
    pub fn markAllCards(self: *Self) void {
        if (self.cards_array) |cards| {
            @memset(cards, 0xff);
        }
        if (self.decks_array) |decks| {
            @memset(decks, 0xff);
        }
    }

    /// Sync context stack pointers from CPU registers to context structure.
    ///
    /// NOTE: This is intentionally a no-op. The JIT code's jit-save-context
    /// template saves R14/R15 (datastack/retainstack) to the context BEFORE
    /// calling any C/Zig code (primitives, inline_cache_miss, etc.). By the
    /// time GC runs, ctx.datastack/retainstack already have the correct values.
    ///
    /// Reading R14/R15 from Zig code gives GARBAGE because Zig uses those
    /// registers for its own purposes (they are callee-saved and may contain
    /// anything). Previously this was overwriting correct context values with
    /// garbage, causing GC to scan wrong stack ranges.
    pub fn syncContextFromRegisters(_: *Self) void {
        // No-op: JIT code already saves context before C calls.
        // See jit-save-context in basis/bootstrap/assembler/x86.64.factor
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

    // Check that a cell has the expected type tag; throws a Factor-level
    // type error (which unwinds the native stack) if the tag doesn't match.
    pub fn checkTag(self: *Self, cell: Cell, expected: layouts.TypeTag) void {
        if (!layouts.hasTag(cell, expected)) {
            self.typeError(expected, cell);
        }
    }

    // --- Error helpers ---
    // These delegate to signals.generalError for common error patterns.

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

    // Extract address from alien, byte-array, or false (null).
    // Shared helper for primitives that accept alien-or-byte-array arguments.
    pub fn alienOffset(self: *Self, obj: Cell) ?[*]u8 {
        const tag = layouts.typeTag(obj);
        if (tag == .byte_array) {
            const ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(obj));
            return ba.data();
        } else if (tag == .alien) {
            const alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(obj));
            std.debug.assert(!(alien.address == 0 and alien.expired != layouts.false_object));
            return @ptrFromInt(alien.address);
        } else if (obj == layouts.false_object) {
            return null;
        }
        self.typeError(.alien, obj);
    }

    // Extract a context pointer from a pinned alien cell.
    pub fn getContextFromAlien(self: *Self, alien_cell: Cell) ?*contexts.Context {
        if (alien_cell == layouts.false_object) return null;
        self.checkTag(alien_cell, .alien);
        const alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(alien_cell));
        if (alien.base != layouts.false_object) {
            self.typeError(.alien, alien_cell);
        }
        return @ptrFromInt(alien.address);
    }

    pub inline fn getCtx(self: *Self) *contexts.Context {
        return self.vm_asm.ctx;
    }

    pub inline fn setCtx(self: *Self, c: *contexts.Context) void {
        self.vm_asm.ctx = c;
    }

    pub inline fn getNursery(self: *Self) *bump_allocator.BumpAllocator {
        return &self.vm_asm.nursery;
    }

    pub inline fn getSpecialObjects(self: *Self) *[objects.special_object_count]Cell {
        return &self.vm_asm.special_objects;
    }

    pub inline fn peek(self: *const Self) Cell {
        return self.vm_asm.ctx.peek();
    }

    pub inline fn pop(self: *Self) Cell {
        return self.vm_asm.ctx.pop();
    }

    pub inline fn push(self: *Self, value: Cell) void {
        self.vm_asm.ctx.push(value);
    }

    pub inline fn replace(self: *Self, value: Cell) void {
        self.vm_asm.ctx.replace(value);
    }

    // === c_to_factor and callback management ===

    // Call Factor code from C/Zig
    // This is the main entry point for calling into compiled Factor code
    pub fn cToFactor(self: *Self, quot: Cell) void {
        // Validate code heap free list before entering Factor
        // validateFreeList checkpoint removed (root cause: non-contiguous heap fixed)

        // First time: create callback stub wrapping c-to-factor word
        if (self.c_to_factor_func == null) {
            self.initCToFactorFunc();
        }

        if (self.c_to_factor_func) |func| {
            // CRITICAL: CALLBACK-STUB switches to spare_ctx immediately!
            // It does: vm->ctx = vm->spare_ctx, then writes to ctx->callstack_save.
            // spare_ctx is eagerly initialized at startup and refreshed in beginCallback.

            // On ARM64 macOS with MAP_JIT, switch to execute mode before calling callback
            if (builtin.cpu.arch == .aarch64 and (builtin.os.tag == .macos or builtin.os.tag == .ios)) {
                const pthread_jit_write_protect_np = struct {
                    extern "c" fn pthread_jit_write_protect_np(enabled: c_int) void;
                }.pthread_jit_write_protect_np;
                pthread_jit_write_protect_np(1); // Enable write protection (allow execution)
            }

            // Call the callback with quotation using explicit inline asm
            // to ensure the first argument register has the correct value
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

    // Initialize the c_to_factor function pointer
    // This must be called after CALLBACK_STUB is available (after image load)
    fn initCToFactorFunc(self: *Self) void {
        // Get C_TO_FACTOR_WORD from special objects
        const c_to_factor_word = self.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.c_to_factor_word)];
        if (c_to_factor_word == layouts.false_object) return;

        // Initialize callback heap if needed
        if (self.callbacks == null) {
            const callback_size = 256 * 1024; // 256KB default
            const heap_ptr = self.allocator.create(CallbackHeap) catch @panic("OOM: callback heap");
            heap_ptr.* = CallbackHeap.init(self.allocator, callback_size) catch {
                self.allocator.destroy(heap_ptr);
                return;
            };
            self.callbacks = heap_ptr;
        }

        // Create callback stub for c_to_factor word
        // The VM pointer we pass is the address of vm_asm (what JIT code uses)
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

    // Called at the beginning of a callback from C to Factor
    // Saves the current state and prepares for Factor execution
    pub fn beginCallback(self: *Self, quot: Cell) Cell {
        self.vm_asm.ctx.reset();

        // Create spare context for nested callbacks
        self.vm_asm.spare_ctx = self.newContext() catch @panic("OOM");

        // Track this callback
        self.callback_ids.append(self.allocator, self.callback_id) catch @panic("OOM");
        self.callback_id += 1;

        self.initContext(self.vm_asm.ctx);

        return quot;
    }

    // Called at the end of a callback from C to Factor
    // Restores the previous state
    pub fn endCallback(self: *Self) void {
        // Pop callback ID
        if (self.callback_ids.items.len > 0) {
            _ = self.callback_ids.pop();
        }

        // Delete current context and switch to spare
        self.deleteContext();
    }

    // Initialize a context for execution
    // Matches C++ VM: init_context() in contexts.cpp
    // Allocates memory (allot_alien)
    pub fn initContext(self: *Self, ctx: *contexts.Context) void {
        // Store an alien wrapping the context pointer in context_objects[OBJ_CONTEXT]
        // This is how Factor code accesses the current context
        // OBJ_CONTEXT = 2 (from C++ context_object enum)
        const ctx_alien = self.allotAlien(layouts.false_object, @intFromPtr(ctx));
        ctx.context_objects[2] = ctx_alien;
    }

    // Allocate an array with given capacity, leaving element slots uninitialized.
    // Caller must initialize all slots before exposing the object to GC scans.
    pub inline fn allotUninitializedArrayNoFill(self: *Self, capacity: Cell) ?Cell {
        const size = layouts.arraySize(layouts.Array, capacity);

        // Use allotObject which handles nursery vs tenured routing
        const tagged = self.allotObject(.array, size) orelse return null;
        const addr = layouts.UNTAG(tagged);
        const array: *layouts.Array = @ptrFromInt(addr);
        array.capacity = layouts.tagFixnum(@as(Fixnum, @intCast(capacity)));
        return tagged;
    }

    // Allocate an array with given capacity.
    // Routes through allotObject() so large arrays go to tenured space.
    // Matches C++: allot_uninitialized_array → allot_array_internal → allot_object
    pub inline fn allotUninitializedArray(self: *Self, capacity: Cell) ?Cell {
        const tagged = self.allotUninitializedArrayNoFill(capacity) orelse return null;
        const array: *layouts.Array = @ptrFromInt(layouts.UNTAG(tagged));

        // Fill with false_object for GC safety — slots may be scanned before
        // the caller fills them. Marked inline so LLVM can fold with caller's fill.
        const cap: usize = @intCast(capacity);
        if (cap > 0) {
            @memset(array.data()[0..cap], layouts.false_object);
        }
        return tagged;
    }

    // Reallocate an array to a new capacity
    // Based on vm/generic_arrays.hpp reallot_array()
    // Returns tagged pointer to resized array (may be same or new allocation)
    pub fn reallotArray(self: *Self, old_array_: Cell, new_capacity: Cell) ?Cell {
        std.debug.assert(layouts.hasTag(old_array_, .array));

        // Root old_array - allotUninitializedArray can trigger GC which may move it
        var old_array = old_array_;
        self.data_roots.append(self.allocator, &old_array) catch @panic("OOM");
        defer _ = self.data_roots.pop();

        const old_arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(old_array));
        const old_capacity = old_arr.getCapacity();

        // If capacity unchanged, return same array
        if (old_capacity == new_capacity) {
            return old_array;
        }

        // Check if we can resize in-place (only if in nursery and shrinking or same size)
        const in_nursery = self.vm_asm.nursery.contains(@ptrFromInt(layouts.UNTAG(old_array)));
        if (in_nursery and new_capacity <= old_capacity) {
            const old_arr_mut: *layouts.Array = @ptrFromInt(layouts.UNTAG(old_array));
            old_arr_mut.capacity = layouts.tagFixnum(@as(Fixnum, @intCast(new_capacity)));
            return old_array;
        }

        // Need to allocate new array - this may trigger GC, moving old_array.
        // Use no-fill allocation because we immediately overwrite copied/grown slots.
        const new_array = self.allotUninitializedArrayNoFill(new_capacity) orelse return null;
        const new_arr: *layouts.Array = @ptrFromInt(layouts.UNTAG(new_array));

        // Re-derive old_arr from rooted old_array (may have been moved by GC)
        const old_arr_after_gc: *layouts.Array = @ptrFromInt(layouts.UNTAG(old_array));

        // Copy existing elements
        const to_copy = @min(old_capacity, new_capacity);
        const old_data = old_arr_after_gc.data();
        const new_data = new_arr.data();

        @memcpy(new_data[0..to_copy], old_data[0..to_copy]);

        // Zero remaining elements if growing
        if (new_capacity > to_copy) {
            @memset(new_data[to_copy..new_capacity], layouts.false_object);
        }

        return new_array;
    }

    // Allocate a byte array
    // Routes through allotObject() so large byte arrays go to tenured space.
    pub fn allotByteArray(self: *Self, size: usize) Cell {
        const header_size = @sizeOf(layouts.ByteArray);
        const total_size = layouts.alignCell(header_size + size, layouts.data_alignment);

        // Use allotObject which handles nursery vs tenured routing
        const tagged = self.allotObject(.byte_array, total_size) orelse {
            self.memoryError();
        };
        const addr = layouts.UNTAG(tagged);
        const ba: *layouts.ByteArray = @ptrFromInt(addr);
        ba.capacity = layouts.tagFixnum(@as(Fixnum, @intCast(size)));

        // Zero the data
        @memset(ba.data()[0..size], 0);

        return tagged;
    }

    // Allocate an alien object (wrapper for a C pointer)
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

    // Allocate a bignum from a Cell value
    // Used by fromUnsignedCell when value doesn't fit in a fixnum
    pub fn allotBignumFromCell(self: *Self, value: Cell) Cell {
        const bignum_mod = @import("bignum.zig");
        const num_digits: Cell = bignum_mod.countDigitsUnsigned(value);
        const total_size: Cell = @sizeOf(layouts.Object) + @sizeOf(Cell) + (num_digits + 1) * @sizeOf(Cell);

        const tagged = self.allotObject(.bignum, total_size) orelse {
            self.memoryError();
        };
        const bn: *bignum_mod.Bignum = @ptrFromInt(layouts.UNTAG(tagged));

        bn.initialize(num_digits, false);
        var val = value;
        var i: Cell = 0;
        while (val != 0) : (i += 1) {
            bn.setDigit(i, val & bignum_mod.DIGIT_MASK);
            val >>= bignum_mod.DIGIT_BITS;
        }

        return tagged;
    }

    // Allocate a bignum from a signed i64 value (negative, doesn't fit in fixnum)
    pub fn allotBignumFromSignedCell(self: *Self, value: i64) Cell {
        const bignum_mod = @import("bignum.zig");
        const abs_value: Cell = @bitCast(if (value == std.math.minInt(i64)) value else -value);
        const num_digits: Cell = bignum_mod.countDigitsUnsigned(abs_value);
        const total_size: Cell = @sizeOf(layouts.Object) + @sizeOf(Cell) + (num_digits + 1) * @sizeOf(Cell);

        const tagged = self.allotObject(.bignum, total_size) orelse {
            self.memoryError();
        };
        const bn: *bignum_mod.Bignum = @ptrFromInt(layouts.UNTAG(tagged));

        bn.initialize(num_digits, true);
        var val = abs_value;
        var i: Cell = 0;
        while (val != 0) : (i += 1) {
            bn.setDigit(i, val & bignum_mod.DIGIT_MASK);
            val >>= bignum_mod.DIGIT_BITS;
        }

        return tagged;
    }

    // === Object Allocation Methods ===

    // Allocate a large object (size >= nursery size) in tenured space.
    // Based on vm/allot.hpp allot_large_object()
    pub fn allotLargeObject(self: *Self, type_tag: layouts.TypeTag, size: Cell) ?Cell {
        const data_heap_mod = @import("data_heap.zig");
        const data_ptr = self.data orelse @panic("data heap not initialized");

        var heap: *data_heap_mod.DataHeap = @ptrCast(@alignCast(data_ptr));

        // Ensure tenured has enough space (compact or grow if needed).
        var required_free = size + heap.highWaterMark();
        if (!heap.tenured.free_list.canAllot(required_free)) {
            if (self.garbage_collector) |gc_instance| {
                gc_instance.gc(.collect_compact) catch @panic("GC compact failed during large object allocation");
            }
        }

        // Heap may have moved during GC; refresh pointer.
        heap = @ptrCast(@alignCast(self.data orelse @panic("data heap lost after compaction")));
        required_free = size + heap.highWaterMark();
        if (!heap.tenured.free_list.canAllot(required_free)) {
            if (self.garbage_collector) |gc_instance| {
                gc_instance.collectGrowingDataHeap(size) catch @panic("GC grow failed during large object allocation");
            }
        }

        heap = @ptrCast(@alignCast(self.data orelse @panic("data heap lost after growing")));
        const addr = heap.allocateTenured(size) orelse @panic("Out of memory in allot_large_object (tenured)");

        // Only pointerful types need the write barrier for old->new refs.
        if (!layouts.typeHasNoPointers(type_tag)) {
            self.writeBarrierRange(addr, size);
        }

        const obj_ptr: *layouts.Object = @ptrFromInt(addr);
        obj_ptr.header = @as(Cell, @intFromEnum(type_tag)) << 2;

        return addr | @intFromEnum(type_tag);
    }

    // Main allocation function - routes to nursery or tenured based on size
    // Based on vm/allot.hpp allot_object()
    pub inline fn allotObject(self: *Self, type_tag: layouts.TypeTag, size: Cell) ?Cell {
        std.debug.assert(!self.current_gc_p);

        // If object is bigger than the nursery, allocate directly in tenured
        if (size >= self.vm_asm.nursery.size) {
            return self.allotLargeObject(type_tag, size);
        }

        // Object fits in nursery - ensure space is available
        if (!self.ensureNurserySpace(size)) return null;

        // Allocate in nursery (ensureNurserySpace guarantees space)
        const addr = self.vm_asm.nursery.allocate(size);

        // Initialize object header
        const obj_ptr: *layouts.Object = @ptrFromInt(addr);
        obj_ptr.header = @as(Cell, @intFromEnum(type_tag)) << 2;

        return addr | @intFromEnum(type_tag);
    }

    // Allocate a code block, triggering compaction if the code heap is full.
    // Matches C++ allot_code_block() in vm/allot.hpp.
    pub fn allotCodeBlock(self: *Self, size: Cell) *code_blocks_mod.CodeBlock {
        const code_heap = self.code orelse @panic("code heap not initialized");

        // First attempt
        if (code_heap.allocate(size)) |block| {
            code_heap.writeBarrier(block) catch {};
            return block;
        }

        // Code heap full — compact GC and retry (same as C++ allot_code_block)
        if (self.garbage_collector) |gc_instance| {
            self.current_gc_p = true;
            defer self.current_gc_p = false;
            gc_instance.collect(.collect_compact);
        }

        // Retry after compaction
        const code_heap2 = self.code orelse @panic("code heap lost after compaction");
        if (code_heap2.allocate(size)) |block| {
            code_heap2.writeBarrier(block) catch {};
            return block;
        }

        // Still can't allocate — fatal
        @panic("Out of memory in allot_code_block");
    }

    // === Garbage Collection Methods ===

    // Update VM fields after replacing the data heap (e.g., after growing).
    // Mirrors C++ factor_vm::set_data_heap.
    pub fn setDataHeap(self: *Self, heap: *DataHeap) void {
        self.data = heap;

        // Keep VM nursery in sync with the heap's nursery.
        self.vm_asm.nursery = heap.nursery;

        // cards_offset/decks_offset satisfy:
        // cards_offset + (addr >> card_bits) = &cards[addr_to_card(addr - heap.start)]
        const data_start = heap.segment.start;
        const cards_ptr = @intFromPtr(heap.cards.cards.ptr);
        const decks_ptr = @intFromPtr(heap.decks.decks.ptr);
        self.vm_asm.cards_offset = @bitCast(cards_ptr -% (data_start >> card_bits));
        self.vm_asm.decks_offset = @bitCast(decks_ptr -% (data_start >> deck_bits));

        // Keep slices for bulk operations (markAllCards, diagnostics).
        self.cards_array = heap.cards.cards;
        self.decks_array = heap.decks.decks;
    }

    // Trigger a minor (nursery) garbage collection
    // This is called when the nursery is full and allocation would fail
    // Uses gc() with automatic escalation: nursery -> aging -> tenured -> full
    pub fn minorGc(self: *Self) void {
        // Skip if GC is disabled (for debugging)
        if (self.gc_off) return;
        if (self.garbage_collector) |gc_instance| {
            self.current_gc_p = true;
            defer self.current_gc_p = false;
            gc_instance.gc(.collect_nursery) catch {
                // Fall back to full collection on failure
                gc_instance.collectFull(true);
            };
        }
    }

    // Trigger a full garbage collection
    pub fn fullGc(self: *Self) void {
        if (self.garbage_collector) |gc_instance| {
            self.current_gc_p = true;
            defer self.current_gc_p = false;
            gc_instance.gc(.collect_full) catch @panic("GC failed");
        }
    }

    // Check if nursery needs collection before allocating size bytes
    // Returns true if allocation can proceed, false if GC failed
    pub fn ensureNurserySpace(self: *Self, size: Cell) bool {
        if (self.vm_asm.nursery.here + size <= self.vm_asm.nursery.end) {
            return true; // Space available
        }

        self.minorGc();
        return self.vm_asm.nursery.here + size <= self.vm_asm.nursery.end;
    }

    // === JIT Compilation Methods ===

    // Get the lazy JIT compile entry point
    pub fn lazyJitCompileEntryPoint(self: *const Self) Cell {
        const lazy_word = self.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.lazy_jit_compile_word)];
        if (lazy_word == layouts.false_object) return 0;
        std.debug.assert(layouts.hasTag(lazy_word, .word));
        const word: *const layouts.Word = @ptrFromInt(layouts.UNTAG(lazy_word));
        return word.entry_point;
    }

    // JIT compile a quotation (main entry point)
    // Matches C++ factor_vm::jit_compile_quotation which uses data_root<quotation>
    pub fn jitCompileQuotation(self: *Self, quot_cell: Cell, relocate: bool) void {
        std.debug.assert(layouts.hasTag(quot_cell, .quotation));

        // CRITICAL: Root the quotation before compilation.
        // jitCompileQuotationWithOwner can trigger GC (nursery allocation in
        // toCodeBlock), which may move this quotation.  Without rooting, the
        // pointer derived from quot_cell becomes stale and the entry_point
        // write below corrupts freed nursery memory.
        // Matches C++: data_root<quotation> quot(quot_, this);
        var rooted_quot = quot_cell;
        self.data_roots.append(self.allocator, &rooted_quot) catch @panic("OOM");
        defer _ = self.data_roots.pop();

        var quot: *layouts.Quotation = @ptrFromInt(layouts.UNTAG(rooted_quot));

        // Check if already compiled
        if (quot.entry_point != 0 and quot.entry_point != self.lazyJitCompileEntryPoint()) {
            return;
        }

        // Compile the quotation - this can trigger GC!
        const compiled = self.jitCompileQuotationWithOwner(rooted_quot, rooted_quot, relocate);

        // Re-derive quot from rooted value after potential GC
        quot = @ptrFromInt(layouts.UNTAG(rooted_quot));

        if (compiled) |cb| {
            quot.entry_point = cb.entryPoint();
        }
    }

    // JIT compile a quotation with explicit owner
    // Matches C++ jit_compile_quotation(cell owner_, cell quot_, bool relocating)
    pub fn jitCompileQuotationWithOwner(self: *Self, owner_in: Cell, quot_cell_in: Cell, relocate: bool) ?*CodeBlock {
        const jit_mod = @import("jit.zig");

        // Root both heap pointers BEFORE QuotationJit.init, which allocates
        // GrowableArrays and can trigger GC. Without rooting, the by-value
        // parameters become stale after GC moves nursery objects.
        // Matches C++ data_root<object> in quotation_jit constructor.
        var owner = owner_in;
        var quot_cell = quot_cell_in;
        self.data_roots.ensureUnusedCapacity(self.allocator, 2) catch @panic("OOM");
        self.data_roots.appendAssumeCapacity(&owner);
        defer _ = self.data_roots.pop();
        self.data_roots.appendAssumeCapacity(&quot_cell);
        defer _ = self.data_roots.pop();

        var compiler = jit_mod.QuotationJit.init(self, owner, true, relocate);
        // Register GC root now that compiler is in its final stack location
        compiler.registerRoot();
        // Fix up potentially stale owner: Jit.init may have triggered GC
        // (via ensureNurserySpace), updating our rooted locals but leaving
        // the by-value copy in the struct stale.
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

        // toCodeBlock adds to uninitialized_blocks (matching C++ add_code_block).
        // If relocating, initialize now (matching C++ jit_compile_quotation line 298-299).
        if (relocate) {
            if (compiled) |block| {
                self.initializeCodeBlockFromMap(@ptrCast(block));
            }
        }

        return compiled;
    }

    // Initialize a code block with relocations
    pub fn initializeCodeBlock(self: *Self, block: *CodeBlock, literals_cell: Cell) void {
        const c_api = @import("c_api.zig");

        // Build relocation context
        // IMPORTANT: vm_ptr must point to vm_asm, not self, because:
        // 1. FactorVM is not an extern struct, so field ordering isn't guaranteed
        // 2. JIT code expects ctx at [r13+0], which is offset 0 of VMAssemblyFields
        // 3. VMAssemblyFields IS an extern struct with ctx at offset 0
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

        // Get literals array if present
        if (literals_cell != layouts.false_object and
            layouts.hasTag(literals_cell, .array))
        {
            ctx.literals = @ptrFromInt(layouts.UNTAG(literals_cell));
        }

        // Get parameters array if present
        if (block.parameters != layouts.false_object and
            layouts.hasTag(block.parameters, .array))
        {
            ctx.parameters = @ptrFromInt(layouts.UNTAG(block.parameters));
        }

        // Apply relocations
        code_blocks_mod.applyRelocations(block, &ctx);

        // Flush instruction cache
        block.flushIcache();

        // CRITICAL: Register code block with remembered sets so GC can update
        // any embedded literals that point to young generation objects
        if (self.code) |code_heap| {
            code_heap.writeBarrier(block) catch @panic("OOM");
            code_heap.updateScanFlags(self.allocator, block);
            code_heap.updateLiteralSites(self.allocator, block);
        }
    }

    // Initialize a code block from the uninitialized_blocks map.
    // Matches C++ initialize_code_block(code_block* compiled) overload which
    // looks up literals in uninitialized_blocks and removes the entry after init.
    pub fn initializeCodeBlockFromMap(self: *Self, block: *code_blocks_mod.CodeBlock) void {
        const code_heap = self.code orelse return;
        const block_addr = @intFromPtr(block);
        if (code_heap.uninitialized_blocks.get(block_addr)) |literals_cell| {
            self.initializeCodeBlock(block, literals_cell);
            _ = code_heap.removeUninitializedBlock(block_addr);
        }
    }

    // ==== DEBUGGER (delegates to debugger.zig) ====

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
    // These must match basis/compiler/constants/constants.factor
    const cell_size = @sizeOf(Cell);

    // VMAssemblyFields layout verification
    // vm-context-offset = 0 bootstrap-cells
    std.debug.assert(@offsetOf(VMAssemblyFields, "ctx") == 0 * cell_size);

    // vm-spare-context-offset = 1 bootstrap-cells
    std.debug.assert(@offsetOf(VMAssemblyFields, "spare_ctx") == 1 * cell_size);

    // nursery starts at offset 2 (ctx and spare_ctx are 2 pointers)
    std.debug.assert(@offsetOf(VMAssemblyFields, "nursery") == 2 * cell_size);

    // nursery is 4 cells, so cards_offset is at offset 6
    std.debug.assert(@offsetOf(VMAssemblyFields, "cards_offset") == 6 * cell_size);

    // decks_offset at offset 7
    std.debug.assert(@offsetOf(VMAssemblyFields, "decks_offset") == 7 * cell_size);

    // vm-signal-handler-addr-offset = 8 bootstrap-cells
    std.debug.assert(@offsetOf(VMAssemblyFields, "signal_handler_addr") == 8 * cell_size);

    // vm-fault-flag-offset = 9 bootstrap-cells
    std.debug.assert(@offsetOf(VMAssemblyFields, "faulting_p") == 9 * cell_size);

    // special_objects starts at offset 10 bootstrap-cells
    std.debug.assert(@offsetOf(VMAssemblyFields, "special_objects") == 10 * cell_size);

    // Note: JIT code uses &vm.vm_asm as the VM pointer, not &vm
    // So offsets within VMAssemblyFields matter (verified above), but
    // the offset of vm_asm within FactorVM doesn't matter for JIT
}
