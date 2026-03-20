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
pub const stack_reserved: Cell = 16384;

pub const FRAME_RETURN_ADDRESS: Cell = if (builtin.cpu.arch == .aarch64) 8 else 0;

pub const CALLSTACK_BOTTOM_OFFSET: Cell = if (builtin.cpu.arch == .aarch64) 6 else 5;

pub const Context = extern struct {
    callstack_top: Cell,
    callstack_bottom: Cell,

    datastack: Cell,

    retainstack: Cell,

    callstack_save: Cell,

    datastack_seg: ?*segments.Segment,
    retainstack_seg: ?*segments.Segment,
    callstack_seg: ?*segments.Segment,

    context_objects: [objects.context_object_count]Cell,

    // Inactive context marker: not in active_contexts.
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
        cs_seg.* = try segments.Segment.initWithGuardPages(cs_size, false, segments.Segment.low_guard_pages);
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
        // Preserve callstack_save so end_callback restores the C stack pointer.
    }

    pub fn isActive(self: *const Self) bool {
        return self.active_index != std.math.maxInt(u32);
    }

    pub fn peek(self: *const Self) Cell {
        return @as(*Cell, @ptrFromInt(self.datastack)).*;
    }

    pub fn replace(self: *Self, tagged: Cell) void {
        @as(*Cell, @ptrFromInt(self.datastack)).* = tagged;
    }

    pub fn pop(self: *Self) Cell {
        const value = self.peek();
        self.datastack -= @sizeOf(Cell);
        return value;
    }

    pub fn push(self: *Self, tagged: Cell) void {
        self.datastack += @sizeOf(Cell);
        self.replace(tagged);
    }

    pub fn peekRetain(self: *const Self) Cell {
        return @as(*Cell, @ptrFromInt(self.retainstack)).*;
    }

    pub fn popRetain(self: *Self) Cell {
        const value = self.peekRetain();
        self.retainstack -= @sizeOf(Cell);
        return value;
    }

    pub fn pushRetain(self: *Self, tagged: Cell) void {
        self.retainstack += @sizeOf(Cell);
        @as(*Cell, @ptrFromInt(self.retainstack)).* = tagged;
    }

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

    pub fn fixStacks(self: *Self) void {
        if (self.datastack_seg) |seg| {
            std.debug.assert(self.datastack <= std.math.maxInt(Cell) - @sizeOf(Cell));
            std.debug.assert(self.datastack <= std.math.maxInt(Cell) - stack_reserved);
            const datastack_min = self.datastack + @sizeOf(Cell);
            const datastack_res = self.datastack + stack_reserved;

            if ((datastack_min < seg.start) or
                (datastack_res >= seg.end))
            {
                self.resetDatastack();
            }
        }

        if (self.retainstack_seg) |seg| {
            std.debug.assert(self.retainstack <= std.math.maxInt(Cell) - @sizeOf(Cell));
            std.debug.assert(self.retainstack <= std.math.maxInt(Cell) - stack_reserved);
            const retainstack_min = self.retainstack + @sizeOf(Cell);
            const retainstack_res = self.retainstack + stack_reserved;

            if ((retainstack_min < seg.start) or
                (retainstack_res >= seg.end))
            {
                self.resetRetainstack();
            }
        }
    }

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

// Fill unused stack memory with a pattern for debugging.
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

comptime {
    std.debug.assert(@offsetOf(Context, "callstack_top") == 0 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Context, "callstack_bottom") == 1 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Context, "datastack") == 2 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Context, "retainstack") == 3 * @sizeOf(Cell));
    std.debug.assert(@offsetOf(Context, "callstack_save") == 4 * @sizeOf(Cell));
}
