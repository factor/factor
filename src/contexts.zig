// contexts.zig - Execution context management
// First 5 fields accessed directly by compiler. See basis/vm/vm.factor

const std = @import("std");
const builtin = @import("builtin");
const layouts = @import("layouts.zig");
const objects = @import("objects.zig");
const segments = @import("segments.zig");
const signals = @import("signals.zig");
const Cell = layouts.Cell;
const VMError = signals.VMError;

// Stack reserved space for overflow handling
// When the callstack fills up, we chop off this many bytes to have space to work with
// macOS 64 bit needs more than 8192. See issue #1419.
pub const stack_reserved: Cell = if (builtin.mode == .Debug) 32768 else 16384;

// Architecture-specific constants for frame layout
// On x86-64: return address is at offset 0 in the frame
// On ARM64: saved frame pointer (x29) is at offset 0, return address (x30) is at offset 8
pub const FRAME_RETURN_ADDRESS: Cell = if (builtin.cpu.arch == .aarch64) 8 else 0;

// Callstack bottom offset calculation
// On x86-64: 5 cells reserved (see vm/cpu-x86.hpp)
// On ARM64: 6 cells reserved (see vm/cpu-arm.64.hpp)
pub const CALLSTACK_BOTTOM_OFFSET: Cell = if (builtin.cpu.arch == .aarch64) 6 else 5;

// Context structure - execution state for a thread/callback
// First 5 fields are accessed directly by compiled Factor code
pub const Context = extern struct {
    callstack_top: Cell,
    callstack_bottom: Cell,

    datastack: Cell,

    retainstack: Cell,

    callstack_save: Cell,

    // Segment pointers (not accessed by compiler, but still in struct)
    datastack_seg: ?*segments.Segment,
    retainstack_seg: ?*segments.Segment,
    callstack_seg: ?*segments.Segment,

    context_objects: [objects.context_object_count]Cell,

    // Context liveness tracking for VM active_contexts list.
    // maxInt(u32) means not in active_contexts.
    active_index: u32,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, ds_size: Cell, rs_size: Cell, cs_size: Cell) !Self {
        var ctx: Self = undefined;

        ctx.callstack_save = 0;
        ctx.datastack_seg = null;
        ctx.retainstack_seg = null;
        ctx.callstack_seg = null;

        const ds_seg = try allocator.create(segments.Segment);
        ds_seg.* = try segments.Segment.init(ds_size, false);
        ctx.datastack_seg = ds_seg;

        const rs_seg = try allocator.create(segments.Segment);
        rs_seg.* = try segments.Segment.init(rs_size, false);
        ctx.retainstack_seg = rs_seg;

        const cs_seg = try allocator.create(segments.Segment);
        cs_seg.* = try segments.Segment.init(cs_size, false);
        ctx.callstack_seg = cs_seg;

        ctx.reset();
        ctx.active_index = std.math.maxInt(u32);

        return ctx;
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        if (self.datastack_seg) |seg| {
            var s = seg;
            s.deinit();
            allocator.destroy(s);
            self.datastack_seg = null;
        }
        if (self.retainstack_seg) |seg| {
            var s = seg;
            s.deinit();
            allocator.destroy(s);
            self.retainstack_seg = null;
        }
        if (self.callstack_seg) |seg| {
            var s = seg;
            s.deinit();
            allocator.destroy(s);
            self.callstack_seg = null;
        }
    }

    pub fn resetDatastack(self: *Self) void {
        if (self.datastack_seg) |seg| {
            self.datastack = seg.start - @sizeOf(Cell);
            fillStackSeg(self.datastack, seg, 0x11111111);
        }
    }

    pub fn resetRetainstack(self: *Self) void {
        if (self.retainstack_seg) |seg| {
            self.retainstack = seg.start - @sizeOf(Cell);
            fillStackSeg(self.retainstack, seg, 0x22222222);
        }
    }

    pub fn resetCallstack(self: *Self) void {
        if (self.callstack_seg) |seg| {
            // Match C++ behavior: callstack_top = callstack_bottom initially
            // This means "empty callstack" - both point to the same place
            //
            // CALLSTACK_BOTTOM is seg->end - sizeof(cell) * N
            // where N = 5 on x86-64, 6 on ARM64
            // The reserved cells are for: return address, saved frame pointer (if any),
            // and extra space for signal handling frame setup.
            // See vm/cpu-x86.hpp and vm/cpu-arm.64.hpp
            const callstack_bottom_offset = @sizeOf(Cell) * CALLSTACK_BOTTOM_OFFSET;
            self.callstack_bottom = seg.end - callstack_bottom_offset;
            self.callstack_top = self.callstack_bottom;
        }
    }

    pub fn resetContextObjects(self: *Self) void {
        @memset(self.context_objects[0..], layouts.false_object);
    }

    pub fn reset(self: *Self) void {
        self.resetDatastack();
        self.resetRetainstack();
        self.resetCallstack();
        self.resetContextObjects();
        // NOTE: Do NOT reset callstack_save here!
        // The C stack pointer is saved by the callback stub before begin_callback runs,
        // and must be preserved so end_callback can restore it when returning to C.
        // The C++ VM only sets callstack_save = 0 in the constructor, not in reset().
    }

    pub inline fn isActive(self: *const Self) bool {
        return self.active_index != std.math.maxInt(u32);
    }

    // Stack operations - used by primitives
    pub inline fn peek(self: *const Self) Cell {
        std.debug.assert(self.datastack % @sizeOf(Cell) == 0);
        std.debug.assert(self.datastackDepth() > 0);
        return @as(*Cell, @ptrFromInt(self.datastack)).*;
    }

    pub inline fn replace(self: *Self, tagged: Cell) void {
        std.debug.assert(self.datastack % @sizeOf(Cell) == 0);
        std.debug.assert(self.datastackDepth() > 0);
        @as(*Cell, @ptrFromInt(self.datastack)).* = tagged;
    }

    pub inline fn pop(self: *Self) Cell {
        const value = self.peek();
        self.datastack -= @sizeOf(Cell);
        return value;
    }

    pub inline fn push(self: *Self, tagged: Cell) void {
        self.datastack += @sizeOf(Cell);
        self.replace(tagged);
    }

    // Retain stack operations
    pub inline fn peekRetain(self: *const Self) Cell {
        return @as(*Cell, @ptrFromInt(self.retainstack)).*;
    }

    pub inline fn popRetain(self: *Self) Cell {
        const value = self.peekRetain();
        self.retainstack -= @sizeOf(Cell);
        return value;
    }

    pub inline fn pushRetain(self: *Self, tagged: Cell) void {
        self.retainstack += @sizeOf(Cell);
        @as(*Cell, @ptrFromInt(self.retainstack)).* = tagged;
    }

    // Stack depth utilities
    pub fn datastackDepth(self: *const Self) Cell {
        if (self.datastack_seg) |seg| {
            return (self.datastack - (seg.start - @sizeOf(Cell))) / @sizeOf(Cell);
        }
        return 0;
    }

    pub fn retainstackDepth(self: *const Self) Cell {
        if (self.retainstack_seg) |seg| {
            return (self.retainstack - (seg.start - @sizeOf(Cell))) / @sizeOf(Cell);
        }
        return 0;
    }

    // Check if an address is within stack bounds
    pub fn datastackInBounds(self: *const Self, ptr: *const Cell) bool {
        const seg = self.datastack_seg orelse return false;
        const addr = @intFromPtr(ptr);
        return addr >= seg.start and addr < seg.end;
    }

    pub fn retainstackInBounds(self: *const Self, ptr: *const Cell) bool {
        const seg = self.retainstack_seg orelse return false;
        const addr = @intFromPtr(ptr);
        return addr >= seg.start and addr < seg.end;
    }

    pub fn callstackInBounds(self: *const Self, ptr: *const Cell) bool {
        const seg = self.callstack_seg orelse return false;
        const addr = @intFromPtr(ptr);
        return addr >= seg.start and addr < seg.end;
    }

    // Fix stack pointers after underflow/overflow
    // Matches C++ VM: fix_stacks() in contexts.cpp
    pub fn fixStacks(self: *Self) void {
        // C++ checks: datastack + sizeof(cell) < datastack_seg->start ||
        //             datastack + stack_reserved >= datastack_seg->end
        if (self.datastack_seg) |seg| {
            if ((self.datastack + @sizeOf(Cell) < seg.start) or
                (self.datastack + stack_reserved >= seg.end))
            {
                self.resetDatastack();
            }
        }

        // C++ checks: retainstack + sizeof(cell) < retainstack_seg->start ||
        //             retainstack + stack_reserved >= retainstack_seg->end
        if (self.retainstack_seg) |seg| {
            if ((self.retainstack + @sizeOf(Cell) < seg.start) or
                (self.retainstack + stack_reserved >= seg.end))
            {
                self.resetRetainstack();
            }
        }
    }

    // Determine which error type corresponds to a faulting address
    // Matches C++ VM: address_to_error() in contexts.cpp
    pub fn addressToError(self: *const Self, addr: Cell) VMError {
        if (self.datastack_seg) |seg| {
            if (seg.isUnderflow(addr))
                return .datastack_underflow;
            if (seg.isOverflow(addr))
                return .datastack_overflow;
        }

        if (self.retainstack_seg) |seg| {
            if (seg.isUnderflow(addr))
                return .retainstack_underflow;
            if (seg.isOverflow(addr))
                return .retainstack_overflow;
        }

        // These are flipped because the callstack grows downwards
        if (self.callstack_seg) |seg| {
            if (seg.isUnderflow(addr))
                return .callstack_overflow;
            if (seg.isOverflow(addr))
                return .callstack_underflow;
        }

        return .memory;
    }
};

// Fill unused stack memory with a pattern for debugging
// Matches C++ VM: fill_stack_seg() in contexts.cpp
// C++ only does this under #ifdef FACTOR_DEBUG
pub fn fillStackSeg(top_ptr: Cell, seg: *segments.Segment, pattern: Cell) void {
    if (comptime @import("builtin").mode == .Debug) {
        const clear_start = top_ptr + @sizeOf(Cell);
        const clear_size = seg.end - clear_start;
        if (clear_size > 0 and clear_start < seg.end) {
            const ptr: [*]Cell = @ptrFromInt(clear_start);
            const count = clear_size / @sizeOf(Cell);
            @memset(ptr[0..count], pattern);
        }
    }
}

// Compile-time verification of struct layout
comptime {
    // First 5 fields must be at specific offsets for assembly compatibility
    std.debug.assert(@offsetOf(Context, "callstack_top") == 0 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Context, "callstack_bottom") == 1 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Context, "datastack") == 2 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Context, "retainstack") == 3 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Context, "callstack_save") == 4 * @sizeOf(Cell));
}
