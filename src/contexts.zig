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

pub const mips_frames = builtin.cpu.arch == .mips or builtin.cpu.arch == .mipsel or builtin.cpu.arch == .mips64 or builtin.cpu.arch == .mips64el;
pub const FRAME_RETURN_ADDRESS: Cell = if (mips_frames) @sizeOf(Cell) else if (builtin.cpu.arch == .powerpc) 4 else if (builtin.cpu.arch == .powerpc64 or builtin.cpu.arch == .powerpc64le) 16 else if (builtin.cpu.arch == .sparc or builtin.cpu.arch == .sparc64) 15 * @sizeOf(Cell) else if (builtin.cpu.arch == .riscv32 or builtin.cpu.arch == .arm) 4 else if (builtin.cpu.arch == .aarch64 or (builtin.cpu.arch == .riscv64 or builtin.cpu.arch == .loongarch64) or builtin.cpu.arch == .s390x) 8 else 0;

// Number of cells subtracted from the callstack segment end to get the
// callstack bottom. Must match the C++ VM (and thus the image's compiled
// subprimitives): aarch64 uses end-32 (CALLSTACK_BOTTOM in cpu-arm.64.hpp),
// x86-64 uses end-40 (cpu-x86.64.hpp).
pub const CALLSTACK_BOTTOM_OFFSET: Cell = if (mips_frames) 32 / @sizeOf(Cell) else if (builtin.cpu.arch == .powerpc) 8 else if (builtin.cpu.arch == .powerpc64 or builtin.cpu.arch == .powerpc64le) 4 else if (builtin.cpu.arch == .sparc or builtin.cpu.arch == .sparc64) @import("sparc.zig").Frame(Cell).minimum_size / @sizeOf(Cell) else if (builtin.cpu.arch == .riscv32 or builtin.cpu.arch == .arm) 8 else if (builtin.cpu.arch == .aarch64 or (builtin.cpu.arch == .riscv64 or builtin.cpu.arch == .loongarch64) or builtin.cpu.arch == .s390x) 4 else 5;

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
        errdefer allocator.destroy(ds_seg);
        ds_seg.* = try segments.Segment.init(ds_size, false);
        errdefer ds_seg.deinit();
        ctx.datastack_seg = ds_seg;

        const rs_seg = try allocator.create(segments.Segment);
        errdefer allocator.destroy(rs_seg);
        rs_seg.* = try segments.Segment.init(rs_size, false);
        errdefer rs_seg.deinit();
        ctx.retainstack_seg = rs_seg;

        const cs_seg = try allocator.create(segments.Segment);
        errdefer allocator.destroy(cs_seg);
        cs_seg.* = try segments.Segment.initWithGuardPages(cs_size, false, segments.Segment.low_guard_pages);
        errdefer cs_seg.deinit();
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
            if (sparc_frames) {
                const root_window: [*]Cell = @ptrFromInt(self.callstack_bottom);
                @memset(root_window[0..16], 0);
            }
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
    if (comptime @import("builtin").mode == .debug) {
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

fn contextAllocationProbe(allocator: std.mem.Allocator) !void {
    var ctx = try Context.init(allocator, 4096, 4096, 16384);
    defer ctx.deinit(allocator);
}

test "context initialization releases earlier stacks on allocation failure" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, contextAllocationProbe, .{});
}

pub const sparc_frames = builtin.cpu.arch == .sparc or builtin.cpu.arch == .sparc64;
pub const FRAME_CHAIN_OFFSET: Cell = if (sparc_frames) 14 * @sizeOf(Cell) else 0;
pub fn frameReturnAddress(top: Cell) Cell {
    if (sparc_frames) return @import("sparc.zig").Frame(Cell).codeAddress(top);
    return @as(*const Cell, @ptrFromInt(top + FRAME_RETURN_ADDRESS)).*;
}
pub fn setFrameReturnAddress(top: Cell, address: Cell) void {
    if (sparc_frames) return @import("sparc.zig").Frame(Cell).setCodeAddress(top, address);
    @as(*Cell, @ptrFromInt(top + FRAME_RETURN_ADDRESS)).* = address;
}
pub fn frameParent(top: Cell) Cell {
    if (sparc_frames) return @import("sparc.zig").Frame(Cell).parent(top);
    const parent = @as(*const Cell, @ptrFromInt(top + FRAME_CHAIN_OFFSET)).*;
    if (builtin.cpu.arch == .powerpc or builtin.cpu.arch == .powerpc64 or builtin.cpu.arch == .powerpc64le) {
        if (parent <= top) {
            std.debug.print("invalid live PowerPC frame top=0x{x} parent=0x{x} lr=0x{x}\n", .{ top, parent, frameReturnAddress(top) });
            @panic("invalid live PowerPC backchain");
        }
    }
    return parent;
}
pub fn capturedFrameSize(top: Cell) Cell {
    return @as(*const Cell, @ptrFromInt(top + FRAME_CHAIN_OFFSET)).*;
}

// Continuation metadata is shared with vm/powerpc_frame.h and cpu-ppc.cpp.
// PPC64 retains its existing signal and stack-walker behavior pending qualification.
pub const powerpc_frames = builtin.cpu.arch == .powerpc and (builtin.os.tag == .linux or builtin.os.tag == .freebsd);
pub const PpcSignalFrameState = enum(u3) { unknown, leaf, pre, active, post, temporary, temporary_leaf };
pub const ppc_signal_marker: Cell = @truncate(@as(u64, 0x5050435349474e00));
pub const ppc_signal_metadata: Cell = 8;

pub inline fn ppcSignalFrameState(top: Cell, size: Cell) ?PpcSignalFrameState {
    if (!powerpc_frames or size != 4 * @sizeOf(Cell)) return null;
    const metadata = @as(*const Cell, @ptrFromInt(top + ppc_signal_metadata)).*;
    const state = metadata & 7;
    if ((metadata & ~@as(Cell, 7)) != ppc_signal_marker or state < 1 or state > 6) return null;
    return @fromBackingInt(@intCast(@as(u3, @intCast(state))));
}

pub inline fn setPpcSignalFrameState(top: Cell, state: PpcSignalFrameState) void {
    @as(*Cell, @ptrFromInt(top + ppc_signal_metadata)).* = ppc_signal_marker | @backingInt(state);
}

pub inline fn capturedFrameAdvance(top: Cell, size: Cell, remaining: Cell) Cell {
    const state = ppcSignalFrameState(top, size);
    if (state == .temporary_leaf) {
        if (remaining < size + 32) @panic("missing PowerPC leaf temporary frame");
        return size + 32;
    }
    if (state == .active or state == .temporary) {
        const extra: Cell = if (state == .temporary) 32 else 0;
        if (remaining <= size + extra) @panic("missing interrupted PowerPC frame");
        const interrupted_size = capturedFrameSize(top + size + extra);
        if (interrupted_size == 0 or interrupted_size > remaining - size - extra) @panic("invalid interrupted PowerPC frame size");
        return size + extra + interrupted_size;
    }
    return size;
}

pub inline fn liveFrameNext(top: Cell, parent: Cell, bottom: Cell) Cell {
    if (!powerpc_frames) return parent;
    if (parent <= top or parent > bottom or parent & 15 != 0) @panic("invalid PowerPC frame bounds");
    const state = ppcSignalFrameState(top, parent - top);
    if (state != .active and state != .temporary and state != .temporary_leaf) return parent;
    if (parent >= bottom) @panic("missing interrupted PowerPC frame");
    var next = frameParent(parent);
    if (next > bottom or next & 15 != 0) @panic("invalid interrupted PowerPC frame bounds");
    if (state == .temporary) {
        if (next >= bottom) @panic("missing PowerPC frame after temporary reservation");
        next = frameParent(next);
        if (next > bottom or next & 15 != 0) @panic("invalid interrupted PowerPC frame bounds");
    }
    return next;
}

pub inline fn frameSpillRootsPresent(top: Cell, size: Cell) bool {
    const state = ppcSignalFrameState(top, size) orelse return true;
    return state == .active or state == .temporary;
}

pub inline fn frameSpillBase(top: Cell, size: Cell) Cell {
    const state = ppcSignalFrameState(top, size);
    if (state == .temporary) return top + size + 32;
    return top + if (state == .active or sparc_frames) size else 0;
}
