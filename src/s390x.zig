//! System z instruction and Linux saved-context fields, independent of host endian.
const std = @import("std");

pub fn branchDisplacement(bytes: [*]const u8) i64 {
    return @as(i64, std.mem.readInt(i32, bytes[2..][0..4], .big)) * 2;
}
pub fn storeBranch(bytes: [*]u8, displacement: i64) void {
    std.debug.assert(displacement & 1 == 0);
    std.debug.assert(displacement >= -4294967296 and displacement <= 4294967294);
    std.mem.writeInt(i32, bytes[2..][0..4], @intCast(@divExact(displacement, 2)), .big);
}
pub fn loadImmediate(bytes: [*]const u8) u64 {
    return (@as(u64, std.mem.readInt(u32, bytes[2..][0..4], .big)) << 32) |
        std.mem.readInt(u32, bytes[8..][0..4], .big);
}
pub fn storeImmediate(bytes: [*]u8, value: u64) void {
    std.mem.writeInt(u32, bytes[2..][0..4], @truncate(value >> 32), .big);
    std.mem.writeInt(u32, bytes[8..][0..4], @truncate(value), .big);
}
pub fn fpcExceptions(fpc: u32) u32 {
    const vic = (fpc >> 8) & 0xf;
    const trapped = if (vic >= 1 and vic <= 5)
        @as(u32, 0x00800000) >> @as(u5, @intCast(vic - 1))
    else
        (fpc & 0x0000f800) << 8;
    return (fpc | trapped) & 0x00f80000;
}
pub fn trapStatus(fpc: u32) u32 {
    const flags = fpcExceptions(fpc);
    var result: u32 = 0;
    if (flags & 0x00800000 != 0) result |= 1;
    if (flags & 0x00400000 != 0) result |= 8;
    if (flags & 0x00200000 != 0) result |= 2;
    if (flags & 0x00100000 != 0) result |= 4;
    if (flags & 0x00080000 != 0) result |= 16;
    return result;
}
// glibc sys/ucontext.h: uc_mcontext at 40, psw.addr at 48,
// gregs[15] at 176, fpregs.fpc at 248. Linux s390x uses 64-bit big-endian cells.
pub const LinuxContext = extern struct {
    flags: u64,
    link: u64,
    stack: [24]u8 align(8),
    psw_mask: u64,
    pc: u64,
    gregs: [16]u64,
    aregs: [16]u32,
    fpc: u32,
    fp_padding: u32,
    fprs: [16]u64,
    sigmask: [128]u8,

    pub fn clearFpuStatus(self: *LinuxContext) void {
        self.fpc &= ~@as(u32, 0x00f8ff00);
    }
};

test "System z halfword branches preserve opcodes and signed extremes" {
    var call = [_]u8{ 0xc0, 0xe5, 0xff, 0xff, 0xff, 0xff };
    try std.testing.expectEqual(@as(i64, -2), branchDisplacement(&call));
    for ([_]i64{ -4294967296, -342, 0, 543210, 4294967294 }) |delta| {
        storeBranch(&call, delta);
        try std.testing.expectEqual(delta, branchDisplacement(&call));
        try std.testing.expectEqual(@as(u8, 0xc0), call[0]);
        try std.testing.expectEqual(@as(u8, 0xe5), call[1]);
    }
}
test "System z split immediate preserves instructions" {
    var bytes = [_]u8{ 0xc0, 0x28, 0, 0, 0, 0, 0xc0, 0x29, 0, 0, 0, 0 };
    storeImmediate(&bytes, 0xfedcba9876543210);
    try std.testing.expectEqual(@as(u64, 0xfedcba9876543210), loadImmediate(&bytes));
    try std.testing.expectEqualSlices(u8, &.{ 0xc0, 0x28, 0xfe, 0xdc, 0xba, 0x98, 0xc0, 0x29, 0x76, 0x54, 0x32, 0x10 }, &bytes);
}
test "Linux System z context offsets and accrued or enabled FP exceptions" {
    try std.testing.expectEqual(@as(usize, 48), @offsetOf(LinuxContext, "pc"));
    try std.testing.expectEqual(@as(usize, 176), @offsetOf(LinuxContext, "gregs") + 15 * 8);
    try std.testing.expectEqual(@as(usize, 248), @offsetOf(LinuxContext, "fpc"));
    for ([_]u32{ 0x00800000, 0x00400000, 0x00200000, 0x00100000, 0x00080000 }, [_]u32{ 1, 8, 2, 4, 16 }) |fpc, trap| {
        try std.testing.expectEqual(trap, trapStatus(fpc));
        try std.testing.expectEqual(trap, trapStatus(fpc >> 8));
    }
    var ctx: LinuxContext = std.mem.zeroes(LinuxContext);
    ctx.fpc = 0xfff8ff03;
    ctx.clearFpuStatus();
    try std.testing.expectEqual(@as(u32, 0xff000003), ctx.fpc);
}

test "Linux vector FP traps decode VIC independently of element index" {
    for ([_]u32{ 1, 8, 2, 4, 16 }, 1..) |status, vic| {
        for (0..4) |element| {
            const vxc: u32 = @intCast((element << 4) | vic);
            try std.testing.expectEqual(status, trapStatus(vxc << 8));
        }
    }
    try std.testing.expectEqual(@as(u32, 1 | 16), trapStatus(0x00800500));
}
