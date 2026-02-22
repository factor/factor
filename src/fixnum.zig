// fixnum.zig - Math primitives with fixnum/bignum handling
// Ported from vm/math.hpp and vm/math.cpp
//
// Factor numbers are either:
// - Fixnums: tagged immediate integers (62 bits on 64-bit)
// - Bignums: arbitrary precision heap-allocated integers
// - Floats: boxed 64-bit IEEE floats (helpers in float.zig)
//
// Arithmetic operations check for overflow and promote to bignum automatically.

const std = @import("std");
const layouts = @import("layouts.zig");
const bignum = @import("bignum.zig");
const objects = @import("objects.zig");
const vm_mod = @import("vm.zig");
const Cell = layouts.Cell;
const Fixnum = layouts.Fixnum;

// Maximum fixnum value (signed)
pub const fixnum_max: Fixnum = (@as(Fixnum, 1) << @as(u6, @intCast(layouts.word_size - layouts.tag_bits - 1))) - 1;
pub const fixnum_min: Fixnum = -fixnum_max - 1;

// Fixnum arithmetic with overflow detection
pub const FixnumResult = union(enum) {
    fixnum: Fixnum,
    overflow: struct { a: Fixnum, b: Fixnum },
};

// Fixnum division (no overflow possible except div by zero)
pub fn div(a: Fixnum, b: Fixnum) ?Fixnum {
    if (b == 0) return null;
    // Handle special case: MIN / -1 overflows
    if (a == fixnum_min and b == -1) return null;
    return @divTrunc(a, b);
}

// Shift operations
pub fn shiftLeft(a: Fixnum, shift: Fixnum) FixnumResult {
    if (shift < 0) {
        // Right shift
        return .{ .fixnum = a >> @intCast(-shift) };
    }
    if (shift >= layouts.word_size - layouts.tag_bits) {
        return .{ .overflow = .{ .a = a, .b = shift } };
    }

    // Check if result would overflow when tagged (matching C++ mask approach)
    // mask has all bits set from bit (WORD_SIZE - 1 - TAG_BITS - shift) upward
    const mask_shift: u6 = @intCast(@as(Fixnum, @intCast(layouts.word_size - 1 - layouts.tag_bits)) - shift);
    const mask = -%(@as(Fixnum, 1) << mask_shift);
    if ((if (a < 0) -a else a) & mask != 0) {
        return .{ .overflow = .{ .a = a, .b = shift } };
    }

    return .{ .fixnum = a << @intCast(shift) };
}

pub fn shiftRight(a: Fixnum, shift: Fixnum) Fixnum {
    std.debug.assert(shift >= 0);
    if (shift >= layouts.word_size) {
        return if (a < 0) -1 else 0;
    }
    return a >> @intCast(shift);
}

// Conversion operations
pub fn toFloat(a: Fixnum) f64 {
    return @floatFromInt(a);
}

pub fn fromFloat(a: f64) ?Fixnum {
    if (a < @as(f64, @floatFromInt(fixnum_min)) or a > @as(f64, @floatFromInt(fixnum_max))) {
        return null;
    }
    return @intFromFloat(a);
}

const FactorVM = vm_mod.FactorVM;

// Helper: convert fixnum to bignum.
// Uses cached constants for 0, 1, -1 (matching C++ BIGNUM_ZERO/BIGNUM_ONE).
// Other values allocate in nursery.
pub inline fn toBignum(vm: *FactorVM, n: Fixnum) !*layouts.Bignum {
    // Fast paths: return cached singletons from special_objects (no allocation)
    if (n == 0) {
        const cached = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.bignum_zero)];
        if (cached != layouts.false_object) {
            return @ptrFromInt(layouts.UNTAG(cached));
        }
    } else if (n == 1) {
        const cached = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.bignum_pos_one)];
        if (cached != layouts.false_object) {
            return @ptrFromInt(layouts.UNTAG(cached));
        }
    } else if (n == -1) {
        const cached = vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.bignum_neg_one)];
        if (cached != layouts.false_object) {
            return @ptrFromInt(layouts.UNTAG(cached));
        }
    }

    const negative = n < 0;
    const abs_n: Cell = if (negative) @bitCast(-n) else @bitCast(n);

    if (abs_n < bignum.RADIX) {
        // Single digit - fast path
        const bn = try bignum.allocBignum(vm, 1, negative);
        bn.setDigit(0, abs_n & bignum.DIGIT_MASK);
        return bn;
    }

    // Multi-digit
    const count: Cell = bignum.countDigitsUnsigned(abs_n);
    const bn = try bignum.allocBignum(vm, count, negative);
    var val = abs_n;
    var i: Cell = 0;
    while (val != 0) : (i += 1) {
        bn.setDigit(i, val & bignum.DIGIT_MASK);
        val >>= bignum.DIGIT_BITS;
    }
    return bn;
}

// Convert unsigned Cell to a Factor value (fixnum or bignum)
pub fn fromUnsignedCell(vm: *FactorVM, n: Cell) Cell {
    const max_fixnum: Cell = @bitCast(@as(Fixnum, std.math.maxInt(Fixnum) >> @intCast(layouts.tag_bits)));
    if (n <= max_fixnum) {
        return layouts.tagFixnum(@intCast(n));
    }
    return vm.allotBignumFromCell(n);
}

// Convert signed i64 to a Factor value (fixnum or bignum)
pub fn fromSignedCell(vm: *FactorVM, n: i64) Cell {
    const min_fixnum = std.math.minInt(Fixnum) >> @as(u6, @intCast(layouts.tag_bits));
    const max_fixnum = std.math.maxInt(Fixnum) >> @as(u6, @intCast(layouts.tag_bits));
    if (n >= min_fixnum and n <= max_fixnum) {
        return layouts.tagFixnum(@intCast(n));
    }
    if (n >= 0) {
        return vm.allotBignumFromCell(@bitCast(n));
    } else {
        return vm.allotBignumFromSignedCell(n);
    }
}

// Convert Factor integer to unsigned (handles fixnums and bignums)
pub fn toUnsignedCell(vm: *FactorVM, n: Cell) Cell {
    const tag = layouts.typeTag(n);
    if (tag == .fixnum) {
        return layouts.untagFixnumUnsigned(n);
    } else if (tag == .bignum) {
        const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(n));
        return bignum.toCell(bn);
    } else {
        vm.typeError(.fixnum, n);
    }
}

// Convert Factor integer to signed (handles fixnums and bignums)
pub fn toSignedCell(vm: *FactorVM, n: Cell) i64 {
    const tag = layouts.typeTag(n);
    if (tag == .fixnum) {
        return layouts.untagFixnum(n);
    } else if (tag == .bignum) {
        const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(n));
        return bignum.toInt64(bn);
    } else {
        vm.typeError(.fixnum, n);
    }
}

// Tests
test "fixnum_max values" {
    // On 64-bit, fixnum uses 60 bits (64 - 4 tag bits)
    // Actually 62 bits for signed (63 - 1 sign bit)
    try std.testing.expect(fixnum_max > 0);
    try std.testing.expect(fixnum_min < 0);
    try std.testing.expect(fixnum_max == -fixnum_min - 1);
}

test "fixnum division" {
    try std.testing.expectEqual(@as(?Fixnum, 2), div(6, 3));
    try std.testing.expectEqual(@as(?Fixnum, -2), div(6, -3));
    try std.testing.expectEqual(@as(?Fixnum, 2), div(7, 3)); // Truncated
    try std.testing.expectEqual(@as(?Fixnum, null), div(1, 0));
}

test "fixnum shifts" {
    try std.testing.expectEqual(FixnumResult{ .fixnum = 8 }, shiftLeft(2, 2));
    try std.testing.expectEqual(@as(Fixnum, 2), shiftRight(8, 2));
    try std.testing.expectEqual(@as(Fixnum, -1), shiftRight(-1, 10)); // Sign extension
}
