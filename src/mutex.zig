const std = @import("std");

pub const SpinMutex = struct {
    const Self = @This();

    state: std.atomic.Value(u8) = std.atomic.Value(u8).init(0),

    pub fn lock(self: *SpinMutex) void {
        while (self.state.cmpxchgWeak(0, 1, .acquire, .monotonic) != null) {
            std.atomic.spinLoopHint();
        }
    }

    pub fn unlock(self: *SpinMutex) void {
        self.state.store(0, .release);
    }
};
