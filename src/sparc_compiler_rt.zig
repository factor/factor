// GNU SPARC32 libgcc lacks LLVM's 128-bit division and conversion entrypoints.
// Use only shifts, comparisons and add/subtract, avoiding recursive lowering.
fn divide(n: u128, d: u128) struct { q: u128, r: u128 } {
    if (d == 0) @trap();
    var q: u128 = 0;
    var r: u128 = 0;
    var bit: u8 = 128;
    while (bit != 0) {
        bit -= 1;
        const overflow = r >> 127 != 0;
        r = (r << 1) | ((n >> @as(u7, @intCast(bit))) & 1);
        if (overflow or r >= d) {
            r -%= d;
            q |= @as(u128, 1) << @as(u7, @intCast(bit));
        }
    }
    return .{ .q = q, .r = r };
}
fn magnitude(value: i128) u128 {
    const bits: u128 = @bitCast(value);
    return if (value < 0) 0 -% bits else bits;
}
pub export fn __udivti3(a: u128, b: u128) callconv(.c) u128 { return divide(a, b).q; }
pub export fn __umodti3(a: u128, b: u128) callconv(.c) u128 { return divide(a, b).r; }
pub export fn __divti3(a: i128, b: i128) callconv(.c) i128 {
    const q = divide(magnitude(a), magnitude(b)).q;
    return @bitCast(if ((a < 0) != (b < 0)) 0 -% q else q);
}
pub export fn __modti3(a: i128, b: i128) callconv(.c) i128 {
    const r = divide(magnitude(a), magnitude(b)).r;
    return @bitCast(if (a < 0) 0 -% r else r);
}
pub export fn __fixdfti(value: f64) callconv(.c) i128 {
    const bits: u64 = @bitCast(value);
    const exponent: i32 = @as(i32, @intCast((bits >> 52) & 0x7ff)) - 1023;
    if (exponent < 0) return 0;
    const mantissa: u128 = (bits & 0xfffffffffffff) | 0x10000000000000;
    const result = if (exponent >= 128) ~@as(u128, 0) >> 1 else if (exponent >= 52)
        mantissa << @as(u7, @intCast(exponent - 52)) else
        mantissa >> @as(u7, @intCast(52 - exponent));
    return @bitCast(if (bits >> 63 != 0) 0 -% result else result);
}
