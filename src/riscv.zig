//! RISC-V relocation fields. Relocation pointers denote the end of the sequence.
const std = @import("std");

pub fn signedField(value: u32, comptime bits: u6) i64 {
    const n = value & ((@as(u32, 1) << bits) - 1);
    return if (n & (@as(u32, 1) << (bits - 1)) != 0)
        @as(i64, n) - (@as(i64, 1) << bits)
    else
        n;
}
pub fn pairDisplacement(p: *align(1) const [2]u32) i64 {
    return @as(i32, @bitCast(p[0] & 0xfffff000)) + signedField(p[1] >> 20, 12);
}
pub fn storePair(p: *align(1) [2]u32, value: i64) void {
    std.debug.assert(value >= std.math.minInt(i32) and value <= std.math.maxInt(i32) - 2048);
    const low = signedField(@truncate(@as(u64, @bitCast(value))), 12);
    p[0] = (p[0] & 0xfff) | (@as(u32, @truncate(@as(u64, @bitCast(value - low)))) & 0xfffff000);
    p[1] = (p[1] & 0xfffff) | ((@as(u32, @truncate(@as(u64, @bitCast(low)))) & 0xfff) << 20);
}
pub fn jalDisplacement(p: u32) i64 {
    return signedField(((p >> 31) << 20) | (((p >> 21) & 0x3ff) << 1) |
        (((p >> 20) & 1) << 11) | (p & 0xff000), 21);
}
pub fn branchDisplacement(p: u32) i64 {
    return signedField(((p >> 31) << 12) | (((p >> 25) & 0x3f) << 5) |
        (((p >> 8) & 0xf) << 1) | (((p >> 7) & 1) << 11), 13);
}
pub fn jalBits(value: i64) u32 {
    std.debug.assert(value >= -1048576 and value < 1048576 and value & 1 == 0);
    const n: u32 = @truncate(@as(u64, @bitCast(value)));
    return ((n & 0x100000) << 11) | ((n & 0x7fe) << 20) | ((n & 0x800) << 9) | (n & 0xff000);
}
pub fn branchBits(value: i64) u32 {
    std.debug.assert(value >= -4096 and value < 4096 and value & 1 == 0);
    const n: u32 = @truncate(@as(u64, @bitCast(value)));
    return ((n & 0x1000) << 19) | ((n & 0x7e0) << 20) | ((n & 0x1e) << 7) | ((n & 0x800) >> 4);
}
pub fn loadLiteral32(p: *align(1) const [2]u32) u32 {
    return (p[0] & 0xfffff000) +% @as(u32, @truncate(@as(u64, @bitCast(signedField(p[1] >> 20, 12)))));
}
pub fn storePair32(p: *align(1) [2]u32, value: u32) void {
    const low: u32 = @truncate(@as(u64, @bitCast(signedField(value, 12))));
    p[0] = (p[0] & 0xfff) | ((value -% low) & 0xfffff000);
    p[1] = (p[1] & 0xfffff) | ((low & 0xfff) << 20);
}
pub fn storeLiteral32(p: *align(1) [2]u32, value: u32) void {
    storePair32(p, value);
}

pub fn loadLiteral(p: *align(1) const [8]u32) u64 {
    var value: u64 = @bitCast(@as(i64, @as(i32, @bitCast(p[0] & 0xfffff000))) + signedField(p[1] >> 20, 12));
    for ([_]usize{ 3, 5, 7 }) |i| value = (value << 12) +% @as(u64, @bitCast(signedField(p[i] >> 20, 12)));
    return value;
}
pub fn storeLiteral(p: *align(1) [8]u32, value: u64) void {
    var v: i64 = @bitCast(value);
    for ([_]usize{ 7, 5, 3 }) |i| {
        const low = signedField(@truncate(@as(u64, @bitCast(v))), 12);
        p[i] = (p[i] & 0xfffff) | ((@as(u32, @truncate(@as(u64, @bitCast(low)))) & 0xfff) << 20);
        v = (v >> 12) + @intFromBool(low < 0);
    }
    const low = signedField(@truncate(@as(u64, @bitCast(v))), 12);
    p[0] = (p[0] & 0xfff) | (@as(u32, @truncate(@as(u64, @bitCast(v - low)))) & 0xfffff000);
    p[1] = (p[1] & 0xfffff) | ((@as(u32, @truncate(@as(u64, @bitCast(low)))) & 0xfff) << 20);
}

test "RV64 relocations preserve opcodes and sign extend displacement" {
    for ([_]i64{ -2147483648, -2049, -2048, -1, 0, 2047, 2048, 2147481599 }) |n| {
        var pair = [_]u32{ 0x297, 0x280e7 };
        storePair(&pair, n);
        try std.testing.expectEqual(n, pairDisplacement(&pair));
        try std.testing.expectEqual(@as(u32, 0x297), pair[0] & 0xfff);
        try std.testing.expectEqual(@as(u32, 0x280e7), pair[1] & 0xfffff);
    }
    var n: i64 = -1048576;
    while (n < 1048576) : (n += 2) try std.testing.expectEqual(n, jalDisplacement(jalBits(n) | 0xef));
    n = -4096;
    while (n < 4096) : (n += 2) try std.testing.expectEqual(n, branchDisplacement(branchBits(n) | 0xb5063));
    var random = std.Random.DefaultPrng.init(0x52563634);
    for (0..100000) |_| {
        const value = random.random().int(u64);
        var code = [_]u32{ 0x537, 0x50513, 0xc51513, 0x50513, 0xc51513, 0x50513, 0xc51513, 0x50513 };
        storeLiteral(&code, value);
        try std.testing.expectEqual(value, loadLiteral(&code));
    }
}

test "RV32 relocations round trip cells and wrapped displacements" {
    var random = std.Random.DefaultPrng.init(0x52563332);
    for (0..100000) |index| {
        const edges = [_]u32{ 0, 1, 2047, 2048, 0x7ffff7ff, 0x7ffff800, 0x80000000, 0xfffff800, 0xffffffff };
        const value = if (index < edges.len) edges[index] else random.random().int(u32);
        var code = [_]u32{ 0x537, 0x50513 };
        storeLiteral32(&code, value);
        try std.testing.expectEqual(value, loadLiteral32(&code));
        try std.testing.expectEqual(@as(u32, 0x537), code[0] & 0xfff);
        try std.testing.expectEqual(@as(u32, 0x50513), code[1] & 0xfffff);
        code = .{ 0x297, 0x280e7 };
        storePair32(&code, value);
        try std.testing.expectEqual(value, @as(u32, @truncate(@as(u64, @bitCast(pairDisplacement(&code))))));
    }
}
