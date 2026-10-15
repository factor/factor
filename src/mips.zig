//! Classic MIPS literal templates and branch fields, in native byte order.
const std = @import("std");
pub fn loadLiteral32(p: *align(1) const [2]u32) u32 {
    return ((p[0] & 0xffff) << 16) | (p[1] & 0xffff);
}
pub fn storeLiteral32(p: *align(1) [2]u32, value: u32) void {
    p[0] = (p[0] & 0xffff0000) | (value >> 16);
    p[1] = (p[1] & 0xffff0000) | (value & 0xffff);
}
pub fn loadLiteral64(p: *align(1) const [7]u32) u64 {
    return (@as(u64, p[0] & 0xffff) << 48) |
        (@as(u64, p[2] & 0xffff) << 32) |
        (@as(u64, p[4] & 0xffff) << 16) | @as(u64, p[6] & 0xffff);
}
pub fn storeLiteral64(p: *align(1) [7]u32, value: u64) void {
    inline for (0..4) |i| {
        p[i * 2] = (p[i * 2] & 0xffff0000) |
            @as(u32, @intCast((value >> (48 - i * 16)) & 0xffff));
    }
}
pub fn branchDisplacement(instruction: u32) i32 {
    return @as(i32, @as(i16, @bitCast(@as(u16, @truncate(instruction))))) * 4;
}
pub fn storeBranch(p: *align(1) u32, displacement: i64) void {
    std.debug.assert(displacement >= -131072 and displacement <= 131068 and displacement & 3 == 0);
    p.* = (p.* & 0xffff0000) |
        (@as(u32, @truncate(@as(u64, @bitCast(@divExact(displacement, 4))))) & 0xffff);
}
test "MIPS literal relocations and exhaustive branch range preserve instruction fields" {
    var li32 = [_]u32{ 0x3c020000, 0x34420000 };
    var li64 = [_]u32{ 0x34020000, 0x00021438, 0x34420000, 0x00021438, 0x34420000, 0x00021438, 0x34420000 };
    var random = std.Random.DefaultPrng.init(42);
    for (0..10000) |_| {
        const n = random.random().int(u64);
        storeLiteral32(&li32, @truncate(n));
        try std.testing.expectEqual(@as(u32, @truncate(n)), loadLiteral32(&li32));
        try std.testing.expectEqual(@as(u32, 0x3c020000), li32[0] & 0xffff0000);
        try std.testing.expectEqual(@as(u32, 0x34420000), li32[1] & 0xffff0000);
        storeLiteral64(&li64, n);
        try std.testing.expectEqual(n, loadLiteral64(&li64));
        inline for ([_]usize{1, 3, 5}) |i| try std.testing.expectEqual(@as(u32, 0x00021438), li64[i]);
    }
    var n: i32 = -131072;
    while (n <= 131068) : (n += 4) {
        var instruction: u32 = 0x10850000;
        storeBranch(&instruction, n);
        try std.testing.expectEqual(n, branchDisplacement(instruction));
        try std.testing.expectEqual(@as(u32, 0x10850000), instruction & 0xffff0000);
    }
}
