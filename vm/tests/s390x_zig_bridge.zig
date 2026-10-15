const trampolines = @import("trampolines");
const s390x = @import("s390x");
comptime {
    @export(&trampolines.trampoline, .{ .name = "trampoline" });
    @export(&trampolines.trampoline2, .{ .name = "trampoline2" });
}
export fn s390x_zig_fpc_status(status: u32) callconv(.c) u32 {
    return s390x.trapStatus(status);
}
export fn s390x_zig_clear_fpc(context: *s390x.LinuxContext) callconv(.c) void {
    context.clearFpuStatus();
}
