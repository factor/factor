// Windows process notifications. Native callbacks only post completion packets;
// they never enter the VM or retain pointers into the Factor heap.
const std = @import("std");
const builtin = @import("builtin");

const HANDLE = *anyopaque;
const invalid_handle: HANDLE = @ptrFromInt(std.math.maxInt(usize));
const infinite = std.math.maxInt(u32);

extern "kernel32" fn GetProcessHeap() callconv(.winapi) HANDLE;
extern "kernel32" fn HeapAlloc(HANDLE, u32, usize) callconv(.winapi) ?*anyopaque;
extern "kernel32" fn HeapFree(HANDLE, u32, *anyopaque) callconv(.winapi) c_int;
extern "kernel32" fn GetLastError() callconv(.winapi) u32;
extern "kernel32" fn SetLastError(u32) callconv(.winapi) void;
extern "kernel32" fn RegisterWaitForSingleObject(
    *HANDLE,
    HANDLE,
    *const fn (?*anyopaque, u8) callconv(.winapi) void,
    ?*anyopaque,
    u32,
    u32,
) callconv(.winapi) c_int;
extern "kernel32" fn UnregisterWaitEx(HANDLE, HANDLE) callconv(.winapi) c_int;
extern "kernel32" fn PostQueuedCompletionStatus(HANDLE, u32, usize, ?*anyopaque) callconv(.winapi) c_int;

const ProcessWait = struct {
    wait: HANDLE,
    port: HANDLE,
    key: usize,
};

fn processWaitCallback(context: ?*anyopaque, _: u8) callconv(.winapi) void {
    const wait: *const ProcessWait = @ptrCast(@alignCast(context.?));
    _ = PostQueuedCompletionStatus(wait.port, 0, wait.key, null);
}

pub fn factor_register_process_wait(process: HANDLE, port: HANDLE, key: usize) callconv(.c) ?*ProcessWait {
    const memory = HeapAlloc(GetProcessHeap(), 0, @sizeOf(ProcessWait)) orelse {
        SetLastError(8); // ERROR_NOT_ENOUGH_MEMORY
        return null;
    };
    const wait: *ProcessWait = @ptrCast(@alignCast(memory));
    wait.* = .{ .wait = undefined, .port = port, .key = key };
    if (RegisterWaitForSingleObject(&wait.wait, process, processWaitCallback, wait, infinite, 0x8) == 0) {
        const err = GetLastError();
        _ = HeapFree(GetProcessHeap(), 0, wait);
        SetLastError(err);
        return null;
    }
    return wait;
}

pub fn factor_unregister_process_wait(wait: *ProcessWait) callconv(.c) c_int {
    // INVALID_HANDLE_VALUE waits for an in-flight callback before freeing its
    // context. On failure the caller retains ownership and the Windows error.
    if (UnregisterWaitEx(wait.wait, invalid_handle) == 0) return 0;
    _ = HeapFree(GetProcessHeap(), 0, wait);
    return 1;
}

comptime {
    if (builtin.os.tag == .windows) {
        @export(&factor_register_process_wait, .{ .name = "factor_register_process_wait" });
        @export(&factor_unregister_process_wait, .{ .name = "factor_unregister_process_wait" });
    }
}

extern "kernel32" fn CreateIoCompletionPort(HANDLE, ?HANDLE, usize, u32) callconv(.winapi) ?HANDLE;
extern "kernel32" fn CreateEventW(?*anyopaque, c_int, c_int, ?[*:0]const u16) callconv(.winapi) ?HANDLE;
extern "kernel32" fn SetEvent(HANDLE) callconv(.winapi) c_int;
extern "kernel32" fn CloseHandle(HANDLE) callconv(.winapi) c_int;
extern "kernel32" fn GetQueuedCompletionStatus(HANDLE, *u32, *usize, *?*anyopaque, u32) callconv(.winapi) c_int;

test "process waits deliver once beyond MAXIMUM_WAIT_OBJECTS" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    const port = CreateIoCompletionPort(invalid_handle, null, 0, 1).?;
    defer _ = CloseHandle(port);
    var events: [128]HANDLE = undefined;
    var waits: [128]*ProcessWait = undefined;
    var count: usize = 0;
    defer for (0..count) |i| {
        std.debug.assert(factor_unregister_process_wait(waits[i]) != 0);
        std.debug.assert(CloseHandle(events[i]) != 0);
    };
    for (0..events.len) |i| {
        const event = CreateEventW(null, 1, @intFromBool(i % 2 == 0), null).?;
        const wait = factor_register_process_wait(event, port, i + 1).?;
        events[i] = event;
        waits[i] = wait;
        count += 1;
        try std.testing.expect(SetEvent(event) != 0);
    }
    var seen: [events.len]bool = @splat(false);
    var bytes: u32 = undefined;
    var key: usize = undefined;
    var overlapped: ?*anyopaque = undefined;
    for (events) |_| {
        try std.testing.expect(GetQueuedCompletionStatus(port, &bytes, &key, &overlapped, 5000) != 0);
        try std.testing.expect(bytes == 0 and overlapped == null);
        try std.testing.expect(key >= 1 and key <= events.len);
        try std.testing.expect(!seen[key - 1]);
        seen[key - 1] = true;
    }
    try std.testing.expect(GetQueuedCompletionStatus(port, &bytes, &key, &overlapped, 50) == 0);
    try std.testing.expectEqual(@as(u32, 258), GetLastError()); // WAIT_TIMEOUT
}

test "unregister before signaling prevents notification" {
    if (builtin.os.tag != .windows) return error.SkipZigTest;
    const port = CreateIoCompletionPort(invalid_handle, null, 0, 1).?;
    defer _ = CloseHandle(port);
    const event = CreateEventW(null, 1, 0, null).?;
    defer _ = CloseHandle(event);
    const wait = factor_register_process_wait(event, port, 1).?;
    try std.testing.expect(factor_unregister_process_wait(wait) != 0);
    try std.testing.expect(SetEvent(event) != 0);
    var bytes: u32 = undefined;
    var key: usize = undefined;
    var overlapped: ?*anyopaque = undefined;
    try std.testing.expect(GetQueuedCompletionStatus(port, &bytes, &key, &overlapped, 50) == 0);
    try std.testing.expectEqual(@as(u32, 258), GetLastError());
}
