// std.Thread currently lacks NetBSD's pthread cancellation enum.
// Use the native pthread ABI for the VM's no-argument workers.
const std = @import("std");
pub const Thread = struct {
    handle: std.c.pthread_t,
    pub fn spawn(_: anytype, comptime function: anytype, _: anytype) !Thread {
        const Entry = struct {
            fn run(_: ?*anyopaque) callconv(.c) ?*anyopaque {
                function();
                return null;
            }
        };
        var handle: std.c.pthread_t = undefined;
        if (std.c.pthread_create(&handle, null, Entry.run, null) != .SUCCESS) return error.ThreadCreationFailed;
        return .{ .handle = handle };
    }
    pub fn getHandle(self: Thread) std.c.pthread_t {
        return self.handle;
    }
    pub fn join(self: Thread) void {
        _ = std.c.pthread_join(self.handle, null);
    }
};
