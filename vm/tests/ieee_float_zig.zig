const std = @import("std");
extern fn factor_fp64_binary(u8, u64, u64, u8, *u64, *u8) c_int;
extern fn factor_fp64_to_i64(u64, u8, *i64, *u8, *u8) c_int;
extern fn factor_fp64_sqrt(u64, u8, *u64, *u8) c_int;
test "software IEEE C bridge from Zig" {
    var bits: u64 = 0;
    var flags: u8 = 0;
    try std.testing.expectEqual(@as(c_int, 0), factor_fp64_binary(0,
        0x3ff0000000000000, 0x3ff0000000000000, 0, &bits, &flags));
    try std.testing.expectEqual(@as(u64, 0x4000000000000000), bits);
    try std.testing.expectEqual(@as(u8, 0), flags);
    var value: i64 = 17;
    var valid: u8 = 1;
    try std.testing.expectEqual(@as(c_int, 0), factor_fp64_to_i64(
        0x7ff8000000000001, 1, &value, &valid, &flags));
    try std.testing.expectEqual(@as(i64, 0), value);
    try std.testing.expectEqual(@as(u8, 0), valid);
    try std.testing.expectEqual(@as(u8, 16), flags);
    bits = 43;
    try std.testing.expectEqual(@as(c_int, 2), factor_fp64_sqrt(
        0x3ff0000000000000, 255, &bits, &flags));
    try std.testing.expectEqual(@as(u64, 43), bits);
    try std.testing.expectEqual(@as(u8, 16), flags);
}
