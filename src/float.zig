// float.zig - Boxed float helpers for the Factor VM.

const std = @import("std");
const layouts = @import("layouts.zig");
const vm_mod = @import("vm.zig");

const Cell = layouts.Cell;
const FactorVM = vm_mod.FactorVM;

// Allocate a boxed float via allotObject (handles nursery/tenured routing).
pub fn allocBoxedFloat(vm: *FactorVM, value: f64) !*layouts.BoxedFloat {
    const size = layouts.alignCell(@sizeOf(layouts.BoxedFloat), layouts.data_alignment);
    const tagged = vm.allotObject(.float, size) orelse return error.OutOfMemory;
    const boxed: *layouts.BoxedFloat = @ptrFromInt(layouts.UNTAG(tagged));
    boxed.n = value;
    return boxed;
}

pub fn allocBoxedFloatBits(vm: *FactorVM, bits: u64) !*layouts.BoxedFloat {
    const size = layouts.alignCell(@sizeOf(layouts.BoxedFloat), layouts.data_alignment);
    const tagged = vm.allotObject(.float, size) orelse return error.OutOfMemory;
    const boxed: *layouts.BoxedFloat = @ptrFromInt(layouts.UNTAG(tagged));
    @memcpy(std.mem.asBytes(&boxed.n), std.mem.asBytes(&bits));
    return boxed;
}

// Precision conversion must preserve NaN encodings without quieting them.
pub fn widenFloatBits(bits: u32) u64 {
    const payload = bits & 0x007fffff;
    if (bits & 0x7f800000 == 0x7f800000 and payload != 0) {
        return (@as(u64, bits & 0x80000000) << 32) |
            0x7ff0000000000000 | (@as(u64, payload) << 29);
    }
    const value: f32 = @bitCast(bits);
    return @bitCast(@as(f64, value));
}

pub fn narrowFloatBits(bits: u64) u32 {
    const payload = bits & 0x000fffffffffffff;
    if (bits & 0x7ff0000000000000 == 0x7ff0000000000000 and payload != 0) {
        const narrowed: u32 = @intCast(payload >> 29);
        return @as(u32, @intCast((bits >> 32) & 0x80000000)) | 0x7f800000 |
            (if (narrowed == 0) @as(u32, 1) else narrowed);
    }
    const value: f64 = @bitCast(bits);
    return @bitCast(@as(f32, @floatCast(value)));
}

test "binary32 NaN encodings survive widening and narrowing" {
    for ([_]u32{ 0, 0x80000000 }) |sign| {
        for (1..0x800000) |payload| {
            const bits = sign | 0x7f800000 | @as(u32, @intCast(payload));
            try std.testing.expectEqual(bits, narrowFloatBits(widenFloatBits(bits)));
        }
    }
    try std.testing.expectEqual(@as(u32, 0x7f800001), narrowFloatBits(0x7ff0000000000001));
    try std.testing.expectEqual(@as(u32, 0xff800001), narrowFloatBits(0xfff0000000000001));
}

// Untag a boxed float value.
pub fn untagFloat(cell: Cell) f64 {
    std.debug.assert(layouts.hasTag(cell, .float));
    const boxed: *const layouts.BoxedFloat = @ptrFromInt(layouts.UNTAG(cell));
    return boxed.n;
}
