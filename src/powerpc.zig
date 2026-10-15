//! PowerPC instruction operands, in the target's native byte order.
const std = @import("std");

pub fn loadLiteral32(p: *align(1) const [2]u32) u32 {
    return ((p[0] & 0xffff) << 16) | (p[1] & 0xffff);
}
pub fn storeLiteral32(p: *align(1) [2]u32, value: u32) void {
    p[0] = (p[0] & 0xffff0000) | (value >> 16);
    p[1] = (p[1] & 0xffff0000) | (value & 0xffff);
}
pub fn loadLiteral64(p: *align(1) const [5]u32) u64 {
    return (@as(u64, p[0] & 0xffff) << 48) | (@as(u64, p[1] & 0xffff) << 32) |
        (@as(u64, p[3] & 0xffff) << 16) | @as(u64, p[4] & 0xffff);
}
pub fn storeLiteral64(p: *align(1) [5]u32, value: u64) void {
    inline for ([_]usize{ 0, 1, 3, 4 }, 0..) |i, n| {
        p[i] = (p[i] & 0xffff0000) | @as(u32, @intCast((value >> (48 - n * 16)) & 0xffff));
    }
}
fn displacementMask(instruction: u32) u32 {
    return if (instruction >> 26 >= 58) 0xfffc else 0xffff;
}
pub fn loadDisplacement(instruction: u32) i16 {
    return @bitCast(@as(u16, @truncate(instruction & displacementMask(instruction))));
}
pub fn storeDisplacement(p: *align(1) u32, value: i64) void {
    const mask = displacementMask(p.*);
    std.debug.assert(value >= -32768 and value <= 32767 and (mask == 0xffff or value & 3 == 0));
    p.* = (p.* & ~mask) | (@as(u32, @truncate(@as(u64, @bitCast(value)))) & mask);
}
pub fn branchDisplacement(instruction: u32) i32 {
    if (instruction >> 26 == 16) return @as(i32, @as(i16, @bitCast(@as(u16, @truncate(instruction & 0xfffc)))));
    std.debug.assert(instruction >> 26 == 18);
    return @as(i32, @bitCast((instruction & 0x03fffffc) << 6)) >> 6;
}
pub fn storeBranch(p: *align(1) u32, value: i64) void {
    const conditional = p.* >> 26 == 16;
    std.debug.assert(conditional or p.* >> 26 == 18);
    const limit: i64 = if (conditional) 32768 else 33554432;
    std.debug.assert(value >= -limit and value < limit and value & 3 == 0);
    const mask: u32 = if (conditional) 0xfffc else 0x03fffffc;
    p.* = (p.* & ~mask) | (@as(u32, @truncate(@as(u64, @bitCast(value)))) & mask);
}

test "PowerPC literal relocations preserve instruction and rotate fields" {
    var p32 = [_]u32{ 0x3c600000, 0x60630000 };
    var p64 = [_]u32{ 0x3c600000, 0x60630000, 0x786307c6, 0x64630000, 0x60630000 };
    var random = std.Random.DefaultPrng.init(42);
    for (0..10000) |_| {
        const value = random.random().int(u64);
        storeLiteral32(&p32, @truncate(value));
        try std.testing.expectEqual(@as(u32, @truncate(value)), loadLiteral32(&p32));
        storeLiteral64(&p64, value);
        try std.testing.expectEqual(value, loadLiteral64(&p64));
        try std.testing.expectEqual(@as(u32, 0x786307c6), p64[2]);
        try std.testing.expectEqual(@as(u32, 0x3c600000), p64[0] & 0xffff0000);
    }
}
test "PowerPC branch and D/DS displacement bounds preserve flags" {
    for ([_]i64{ -33554432, -4, 0, 4, 33554428 }) |value| {
        var instruction: u32 = 0x48000003;
        storeBranch(&instruction, value);
        try std.testing.expectEqual(@as(i32, @intCast(value)), branchDisplacement(instruction));
        try std.testing.expectEqual(@as(u32, 0x48000003), instruction & 0xfc000003);
    }
    var value: i64 = -32768;
    while (value <= 32764) : (value += 4) {
        var instruction: u32 = 0x41820001;
        storeBranch(&instruction, value);
        try std.testing.expectEqual(@as(i32, @intCast(value)), branchDisplacement(instruction));
        try std.testing.expectEqual(@as(u32, 0x41820001), instruction & 0xffff0003);
        var ds: u32 = 0xe8630001;
        storeDisplacement(&ds, value);
        try std.testing.expectEqual(@as(i16, @intCast(value)), loadDisplacement(ds));
        try std.testing.expectEqual(@as(u32, 0xe8630001), ds & 0xffff0003);
    }
    for ([_]i64{ -32768, -1, 0, 1, 32767 }) |v| {
        var d: u32 = 0x80630000;
        storeDisplacement(&d, v);
        try std.testing.expectEqual(@as(i16, @intCast(v)), loadDisplacement(d));
    }
}
