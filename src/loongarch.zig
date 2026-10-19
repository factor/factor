const std = @import("std");
pub fn signedField(value: u32, comptime bits: u6) i64 {
    const mask = (@as(u32, 1) << bits) - 1;
    const n = value & mask;
    return if (n & (@as(u32, 1) << (bits - 1)) != 0) @as(i64, n) - (@as(i64, 1) << bits) else n;
}
pub fn isJirl(opcode: u32) bool {
    return opcode & 0xfc000000 == 0x4c000000;
}
pub fn pairDisplacement(p: *align(1) const [2]u32) i64 {
    return signedField(p[0] >> 5, 20) * 4096 +
        (if (isJirl(p[1])) signedField(p[1] >> 10, 16) * 4 else signedField(p[1] >> 10, 12));
}
pub fn storePair(p: *align(1) [2]u32, value: i64) void {
    const low = signedField(@truncate(@as(u64, @bitCast(value))), 12);
    const high = @divExact(value - low, 4096);
    std.debug.assert(high >= -524288 and high < 524288);
    p[0] = (p[0] & 0xfe00001f) | ((@as(u32, @truncate(@as(u64, @bitCast(high)))) & 0xfffff) << 5);
    if (isJirl(p[1])) {
        std.debug.assert(low & 3 == 0);
        p[1] = (p[1] & 0xfc0003ff) | ((@as(u32, @truncate(@as(u64, @bitCast(@divExact(low, 4))))) & 0xffff) << 10);
    } else p[1] = (p[1] & 0xffc003ff) | ((@as(u32, @truncate(@as(u64, @bitCast(low)))) & 0xfff) << 10);
}
pub fn loadLiteral(p: *align(1) const [8]u32) u64 {
    var value: u64 = @bitCast(signedField(p[0] >> 5, 20) * 4096 + signedField(p[1] >> 10, 12));
    inline for (.{ 3, 5, 7 }) |i| value = (value << 12) +% @as(u64, @bitCast(signedField(p[i] >> 10, 12)));
    return value;
}
pub fn storeLiteral(p: *align(1) [8]u32, value: u64) void {
    var v: i64 = @bitCast(value);
    inline for (.{ 7, 5, 3, 1 }) |i| {
        const low = signedField(@truncate(@as(u64, @bitCast(v))), 12);
        p[i] = (p[i] & 0xffc003ff) | ((@as(u32, @truncate(@as(u64, @bitCast(low)))) & 0xfff) << 10);
        v = (v >> 12) + @intFromBool(low < 0);
    }
    p[0] = (p[0] & 0xfe00001f) | ((@as(u32, @truncate(@as(u64, @bitCast(v)))) & 0xfffff) << 5);
}
pub fn trapStatus(raw: u32) u32 {
    const status = raw | (raw >> 8);
    var r: u32 = 0;
    if (status & 0x100000 != 0) r |= 0x01;
    if (status & 0x080000 != 0) r |= 0x08;
    if (status & 0x040000 != 0) r |= 0x02;
    if (status & 0x020000 != 0) r |= 0x04;
    if (status & 0x010000 != 0) r |= 0x10;
    return r;
}
pub fn signalTrapStatus(raw: u32, code: c_int) u32 {
    const status = trapStatus(raw);
    return status | @as(u32, switch (code) {
        3 => 8, // FPE_FLTDIV
        4 => 2, // FPE_FLTOVF
        5 => 4, // FPE_FLTUND
        6 => 16, // FPE_FLTRES
        7 => 1, // FPE_FLTINV
        else => 0,
    });
}
test "LoongArch instruction operands round trip signed boundaries" {
    var literal = [_]u32{ 0x14000004, 0x02c00084, 0x00413084, 0x02c00084, 0x00413084, 0x02c00084, 0x00413084, 0x02c00084 };
    for ([_]u64{ 0, 2048, std.math.maxInt(u64), 0x8000000000000000, 0x123456789abcdef0 }) |value| {
        storeLiteral(&literal, value);
        try std.testing.expectEqual(value, loadLiteral(&literal));
    }
    for ([_]i64{ -2147483648, -4096, -4, 0, 2048, 2147481596 }) |value| {
        var pair = [_]u32{ 0x1c00000c, 0x4c000181 };
        storePair(&pair, value);
        try std.testing.expectEqual(value, pairDisplacement(&pair));
    }
}

test "LoongArch enabled FPU traps decode cause bits" {
    try std.testing.expectEqual(@as(u32, 8), trapStatus(0x08000008));
    try std.testing.expectEqual(@as(u32, 31), trapStatus(0x1f00001f));
    try std.testing.expectEqual(@as(u32, 31), trapStatus(0x001f0000));
}

test "LoongArch Linux signal codes survive cleared FCSR causes" {
    try std.testing.expectEqual(@as(u32, 8), signalTrapStatus(8, 3));
    try std.testing.expectEqual(@as(u32, 31), signalTrapStatus(0x1f000000, 3));
    try std.testing.expectEqual(@as(u32, 0), signalTrapStatus(31, 1));
    try std.testing.expectEqual(@as(u32, 18), signalTrapStatus(0x01010004, 4));
}
