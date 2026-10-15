const gates = @import("trampolines");
comptime {
    @export(&gates.trampoline, .{ .name = "trampoline" });
    @export(&gates.trampoline2, .{ .name = "trampoline2" });
}
