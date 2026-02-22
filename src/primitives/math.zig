// primitives/math.zig - Number type conversions, fixnum/bignum/float arithmetic

const std = @import("std");
const bignum = @import("../bignum.zig");
const float_mod = @import("../float.zig");
const layouts = @import("../layouts.zig");
const fixnum = @import("../fixnum.zig");
const objects = @import("../objects.zig");
const vm_mod = @import("../vm.zig");

const Cell = layouts.Cell;
const Fixnum = layouts.Fixnum;
const FactorVM = vm_mod.FactorVM;
const VMAssemblyFields = vm_mod.VMAssemblyFields;

// --- Number Type Conversion Primitives ---

pub export fn primitive_fixnum_to_bignum(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const n = layouts.untagFixnum(ctx.peek());
    const bn = fixnum.toBignum(vm, n) catch {
        vm.memoryError();
    };
    ctx.replace(layouts.tagBignum(bn));
}

pub export fn primitive_bignum_to_fixnum(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    const bn_cell = ctx.peek();
    if (!layouts.hasTag(bn_cell, .bignum)) {
        ctx.replace(layouts.tagFixnum(0));
        return;
    }
    const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(bn_cell));
    const result = bignum.toFixnum(bn);
    ctx.replace(layouts.tagFixnum(result));
}

pub export fn primitive_bignum_to_fixnum_strict(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const bn_cell = ctx.peek();
    if (!layouts.hasTag(bn_cell, .bignum)) {
        vm.typeError(.bignum, bn_cell);
    }
    const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(bn_cell));
    if (!bignum.fitsFixnum(bn)) {
        vm.fixnumRangeError(bn_cell);
    }
    const result = bignum.toFixnum(bn);
    ctx.replace(layouts.tagFixnum(result));
}

pub export fn primitive_bignum_to_float(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const bn_cell = ctx.peek();
    if (!layouts.hasTag(bn_cell, .bignum)) {
        ctx.replace(layouts.tagFixnum(0));
        return;
    }
    const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(bn_cell));

    // Convert bignum to float
    // Start with 0.0 and accumulate: for each digit from MSB to LSB: result = result * radix + digit
    var result: f64 = 0.0;
    const len = bn.length();

    // Iterate from most significant to least significant digit
    var i: Cell = len;
    while (i > 0) {
        i -= 1;
        const digit = bn.getDigit(i);
        // result = result * 2^DIGIT_BITS + digit
        result = result * @as(f64, @floatFromInt(bignum.RADIX)) + @as(f64, @floatFromInt(digit));
    }

    // Apply sign
    if (bn.isNegative()) {
        result = -result;
    }

    const boxed = float_mod.allocBoxedFloat(vm, result) catch vm.memoryError();
    ctx.replace(layouts.tagFloat(boxed));
}

pub export fn primitive_fixnum_to_float(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const n = layouts.untagFixnum(ctx.peek());
    const f = fixnum.toFloat(n);
    const boxed = float_mod.allocBoxedFloat(vm, f) catch vm.memoryError();
    ctx.replace(layouts.tagFloat(boxed));
}

pub export fn primitive_float_to_fixnum(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    const float_cell = ctx.peek();
    const f = float_mod.untagFloat(float_cell);
    if (fixnum.fromFloat(f)) |result| {
        ctx.replace(layouts.tagFixnum(result));
    } else {
        // Overflow - would need bignum
        ctx.replace(layouts.false_object);
    }
}

pub export fn primitive_float_to_bignum(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const float_cell = ctx.peek();
    const f = float_mod.untagFloat(float_cell);

    // Handle special cases: NaN, Inf, and values too large for i128
    // C++ returns BIGNUM_ZERO() for all these cases
    const truncated = @trunc(f);
    if (std.math.isNan(f) or std.math.isInf(f) or
        truncated < @as(f64, @floatFromInt(std.math.minInt(i128))) or
        truncated > @as(f64, @floatFromInt(std.math.maxInt(i128))))
    {
        const total_size = @sizeOf(bignum.Bignum) + @sizeOf(Cell);
        const zero_tagged = vm.allotObject(.bignum, total_size) orelse {
            vm.memoryError();
        };
        const bn: *bignum.Bignum = @ptrFromInt(layouts.UNTAG(zero_tagged));
        bn.capacity = layouts.tagFixnum(1);
        bn.setNegative(false);
        ctx.replace(zero_tagged);
        return;
    }

    const int_val: i128 = @intFromFloat(truncated);

    // Handle zero
    if (int_val == 0) {
        const total_size = @sizeOf(bignum.Bignum) + @sizeOf(Cell);
        const zero_tagged = vm.allotObject(.bignum, total_size) orelse {
            vm.memoryError();
        };
        const bn: *bignum.Bignum = @ptrFromInt(layouts.UNTAG(zero_tagged));
        bn.capacity = layouts.tagFixnum(1);
        bn.setNegative(false);
        ctx.replace(zero_tagged);
        return;
    }

    // Determine sign and absolute value
    const negative = int_val < 0;
    const abs_val: u128 = if (negative) @bitCast(-int_val) else @bitCast(int_val);

    // Count how many bignum digits we need
    const digit_bits = bignum.DIGIT_BITS;
    const digit_mask = bignum.DIGIT_MASK;

    var temp = abs_val;
    var num_digits: Cell = 0;
    while (temp != 0) : (temp >>= digit_bits) {
        num_digits += 1;
    }

    // Allocate bignum
    const total_size = @sizeOf(bignum.Bignum) + (num_digits + 1) * @sizeOf(Cell);
    const bn_tagged = vm.allotObject(.bignum, total_size) orelse {
        vm.memoryError();
    };
    const bn: *bignum.Bignum = @ptrFromInt(layouts.UNTAG(bn_tagged));
    bn.capacity = layouts.tagFixnum(@intCast(num_digits + 1));
    bn.setNegative(negative);

    // Fill in the digits (little-endian)
    temp = abs_val;
    for (0..num_digits) |i| {
        bn.setDigit(i, @truncate(temp & digit_mask));
        temp >>= digit_bits;
    }

    ctx.replace(bn_tagged);
}

// --- Fixnum Arithmetic Primitives ---

pub export fn primitive_fixnum_divint(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    const b = layouts.untagFixnum(ctx.pop());
    const a = layouts.untagFixnum(ctx.peek());

    if (b == 0) {
        const vm = vm_asm.getVM();
        vm.divideByZeroError();
    }

    if (fixnum.div(a, b)) |result| {
        ctx.replace(layouts.tagFixnum(result));
    } else {
        // Overflow (MIN / -1) - promote to bignum
        if (a == fixnum.fixnum_min and b == -1) {
            const vm = vm_asm.getVM();
            const bn = fixnum.toBignum(vm, -fixnum.fixnum_min) catch vm.memoryError();
            ctx.replace(layouts.tagBignum(bn));
        } else {
            unreachable;
        }
    }
}

pub export fn primitive_fixnum_divmod(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    const ds = ctx.datastack;
    const b_ptr: *Cell = @ptrFromInt(ds);
    const a_ptr: *Cell = @ptrFromInt(ds - @sizeOf(Cell));

    const b = layouts.untagFixnum(b_ptr.*);
    const a = layouts.untagFixnum(a_ptr.*);

    if (b == -1 and a == fixnum.fixnum_min) {
        // Special case: overflow
        const vm = vm_asm.getVM();
        const bn = fixnum.toBignum(vm, -fixnum.fixnum_min) catch vm.memoryError();
        a_ptr.* = layouts.tagBignum(bn);
        b_ptr.* = layouts.tagFixnum(0);
    } else if (b != 0) {
        const quot = @divTrunc(a, b);
        const rem = @rem(a, b);
        a_ptr.* = layouts.tagFixnum(quot);
        b_ptr.* = layouts.tagFixnum(rem);
    } else {
        const vm = vm_asm.getVM();
        vm.divideByZeroError();
    }
}

pub export fn primitive_fixnum_shift(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    const shift_amt = layouts.untagFixnum(ctx.pop());
    const value = layouts.untagFixnum(ctx.peek());
    if (value == 0) {
        return; // 0 shifted is still 0
    }

    if (shift_amt < 0) {
        // Right shift
        const result = fixnum.shiftRight(value, -shift_amt);
        ctx.replace(layouts.tagFixnum(result));
    } else {
        // Left shift - may overflow to bignum
        const result = fixnum.shiftLeft(value, shift_amt);
        switch (result) {
            .fixnum => |n| ctx.replace(layouts.tagFixnum(n)),
            .overflow => {
                // Promote to bignum and shift
                const vm = vm_asm.getVM();
                const bn = fixnum.toBignum(vm, value) catch vm.memoryError();
                const shifted = bignum.shift(vm, bn, shift_amt) catch vm.memoryError();
                ctx.replace(layouts.tagBignum(shifted));
            },
        }
    }
}

// --- Bignum Arithmetic Primitives ---

// Convert cell to tagged bignum cell, converting fixnum if needed.
// Called on the slow path when compiler constant folding passes fixnums
// to bignum-specific primitives.
fn ensureBignumCell(vm: *FactorVM, cell_val: Cell) Cell {
    const tag = layouts.typeTag(cell_val);
    if (tag == .bignum) return cell_val;
    if (tag == .fixnum) {
        const bn = fixnum.toBignum(vm, layouts.untagFixnum(cell_val)) catch vm.memoryError();
        return layouts.tagBignum(bn);
    }
    vm.typeError(.bignum, cell_val);
}

// Binary bignum arithmetic slow path: handles fixnum args from compiler
// constant folding. Converts to bignums with proper GC rooting.
// Only 'a' is rooted here because opFn internally roots both operands
// before any allocation. Passing 'b' unrooted avoids double-rooting.
noinline fn binaryBignumSlow(
    vm: *FactorVM,
    a_cell: Cell,
    b_cell: Cell,
    comptime opFn: fn (*FactorVM, *const bignum.Bignum, *const bignum.Bignum) anyerror!*bignum.Bignum,
) *bignum.Bignum {
    var a_tagged = ensureBignumCell(vm, a_cell);
    vm.data_roots.append(vm.allocator, &a_tagged) catch vm.memoryError();
    defer _ = vm.data_roots.pop();
    const b: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(ensureBignumCell(vm, b_cell)));
    const a: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(a_tagged));
    return opFn(vm, a, b) catch vm.memoryError();
}

// Binary bignum comparison slow path: handles fixnum args.
noinline fn binaryBignumCmpSlow(vm: *FactorVM, a_cell: Cell, b_cell: Cell) bignum.Comparison {
    var a_tagged = ensureBignumCell(vm, a_cell);
    vm.data_roots.append(vm.allocator, &a_tagged) catch vm.memoryError();
    defer _ = vm.data_roots.pop();
    const b: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(ensureBignumCell(vm, b_cell)));
    const a: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(a_tagged));
    return bignum.compare(a, b);
}

pub export fn primitive_bignum_add(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b_cell = ctx.pop();
    const a_cell = ctx.peek();
    const result = if (layouts.typeTag(a_cell) == .bignum and layouts.typeTag(b_cell) == .bignum)
        bignum.add(vm, @ptrFromInt(layouts.UNTAG(a_cell)), @ptrFromInt(layouts.UNTAG(b_cell))) catch vm.memoryError()
    else
        binaryBignumSlow(vm, a_cell, b_cell, bignum.add);
    ctx.replace(layouts.tagBignum(result));
}

pub export fn primitive_bignum_subtract(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b_cell = ctx.pop();
    const a_cell = ctx.peek();
    const result = if (layouts.typeTag(a_cell) == .bignum and layouts.typeTag(b_cell) == .bignum)
        bignum.subtract(vm, @ptrFromInt(layouts.UNTAG(a_cell)), @ptrFromInt(layouts.UNTAG(b_cell))) catch vm.memoryError()
    else
        binaryBignumSlow(vm, a_cell, b_cell, bignum.subtract);
    ctx.replace(layouts.tagBignum(result));
}

pub export fn primitive_bignum_multiply(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b_cell = ctx.pop();
    const a_cell = ctx.peek();
    const result = if (layouts.typeTag(a_cell) == .bignum and layouts.typeTag(b_cell) == .bignum)
        bignum.multiply(vm, @ptrFromInt(layouts.UNTAG(a_cell)), @ptrFromInt(layouts.UNTAG(b_cell))) catch vm.memoryError()
    else
        binaryBignumSlow(vm, a_cell, b_cell, bignum.multiply);
    std.debug.assert(result.length() == 0 or result.getDigit(result.length() - 1) != 0);
    ctx.replace(layouts.tagBignum(result));
}

pub export fn primitive_bignum_divint(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b_cell = ctx.pop();
    const a_cell = ctx.peek();
    const result = if (layouts.typeTag(a_cell) == .bignum and layouts.typeTag(b_cell) == .bignum)
        bignum.quotient(vm, @ptrFromInt(layouts.UNTAG(a_cell)), @ptrFromInt(layouts.UNTAG(b_cell))) catch vm.memoryError()
    else
        binaryBignumSlow(vm, a_cell, b_cell, bignum.quotient);
    ctx.replace(layouts.tagBignum(result));
}

pub export fn primitive_bignum_divmod(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const ds = ctx.datastack;
    const b_ptr: *Cell = @ptrFromInt(ds);
    const a_ptr: *Cell = @ptrFromInt(ds - @sizeOf(Cell));

    var a_val = a_ptr.*;
    var b_val = b_ptr.*;
    if (layouts.typeTag(a_val) != .bignum or layouts.typeTag(b_val) != .bignum) {
        a_val = ensureBignumCell(vm, a_val);
        vm.data_roots.append(vm.allocator, &a_val) catch vm.memoryError();
        defer _ = vm.data_roots.pop();
        b_val = ensureBignumCell(vm, b_val);
    }
    const a: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(a_val));
    const b: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(b_val));

    const div_result = bignum.divmod(vm, a, b) catch vm.memoryError();

    a_ptr.* = layouts.tagBignum(div_result.quotient);
    if (bignum.fitsFixnum(div_result.remainder)) {
        b_ptr.* = layouts.tagFixnum(bignum.toFixnum(div_result.remainder));
    } else {
        b_ptr.* = layouts.tagBignum(div_result.remainder);
    }
}

pub export fn primitive_bignum_and(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b_cell = ctx.pop();
    const a_cell = ctx.peek();
    const a_tag = layouts.typeTag(a_cell);
    const b_tag = layouts.typeTag(b_cell);

    // Fast path: non-negative bignum AND non-negative fixnum → fixnum result.
    // Zero allocations. Hot in >be (nth-byte = shift then 0xff bitand).
    if (a_tag == .bignum and b_tag == .fixnum) {
        const fixval = layouts.untagFixnum(b_cell);
        if (fixval >= 0) {
            const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(a_cell));
            if (!bn.isNegative()) {
                const low = if (bn.isZero()) @as(Cell, 0) else bn.getDigit(0);
                ctx.replace(layouts.tagFixnum(@bitCast(low & @as(Cell, @bitCast(fixval)))));
                return;
            }
        }
    }
    if (a_tag == .fixnum and b_tag == .bignum) {
        const fixval = layouts.untagFixnum(a_cell);
        if (fixval >= 0) {
            const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(b_cell));
            if (!bn.isNegative()) {
                const low = if (bn.isZero()) @as(Cell, 0) else bn.getDigit(0);
                ctx.replace(layouts.tagFixnum(@bitCast(low & @as(Cell, @bitCast(fixval)))));
                return;
            }
        }
    }

    const result = if (a_tag == .bignum and b_tag == .bignum)
        bignum.bitAnd(vm, @ptrFromInt(layouts.UNTAG(a_cell)), @ptrFromInt(layouts.UNTAG(b_cell))) catch vm.memoryError()
    else
        binaryBignumSlow(vm, a_cell, b_cell, bignum.bitAnd);
    ctx.replace(layouts.tagBignum(result));
}

pub export fn primitive_bignum_or(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b_cell = ctx.pop();
    const a_cell = ctx.peek();
    const result = if (layouts.typeTag(a_cell) == .bignum and layouts.typeTag(b_cell) == .bignum)
        bignum.bitOr(vm, @ptrFromInt(layouts.UNTAG(a_cell)), @ptrFromInt(layouts.UNTAG(b_cell))) catch vm.memoryError()
    else
        binaryBignumSlow(vm, a_cell, b_cell, bignum.bitOr);
    ctx.replace(layouts.tagBignum(result));
}

pub export fn primitive_bignum_xor(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b_cell = ctx.pop();
    const a_cell = ctx.peek();
    const result = if (layouts.typeTag(a_cell) == .bignum and layouts.typeTag(b_cell) == .bignum)
        bignum.bitXor(vm, @ptrFromInt(layouts.UNTAG(a_cell)), @ptrFromInt(layouts.UNTAG(b_cell))) catch vm.memoryError()
    else
        binaryBignumSlow(vm, a_cell, b_cell, bignum.bitXor);
    ctx.replace(layouts.tagBignum(result));
}

pub export fn primitive_bignum_not(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const a_cell = ctx.peek();
    const a: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(ensureBignumCell(vm, a_cell)));
    const result = bignum.bitNot(vm, a) catch vm.memoryError();
    ctx.replace(layouts.tagBignum(result));
}

pub export fn primitive_bignum_shift(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const shift_cell = ctx.pop();
    const bn_cell = ctx.peek();
    const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(ensureBignumCell(vm, bn_cell)));
    const shift_amt = layouts.untagFixnum(shift_cell);
    const result = bignum.shift(vm, bn, shift_amt) catch vm.memoryError();
    ctx.replace(layouts.tagBignum(result));
}

pub export fn primitive_bignum_eq(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b_cell = ctx.pop();
    const a_cell = ctx.peek();
    if (layouts.typeTag(a_cell) == .bignum and layouts.typeTag(b_cell) == .bignum) {
        const result = bignum.equal(@ptrFromInt(layouts.UNTAG(a_cell)), @ptrFromInt(layouts.UNTAG(b_cell)));
        ctx.replace(vm.tagBoolean(result));
    } else {
        const cmp = binaryBignumCmpSlow(vm, a_cell, b_cell);
        ctx.replace(vm.tagBoolean(cmp == .equal));
    }
}

pub export fn primitive_bignum_less(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b_cell = ctx.pop();
    const a_cell = ctx.peek();
    if (layouts.typeTag(a_cell) == .bignum and layouts.typeTag(b_cell) == .bignum) {
        const cmp = bignum.compare(@ptrFromInt(layouts.UNTAG(a_cell)), @ptrFromInt(layouts.UNTAG(b_cell)));
        ctx.replace(vm.tagBoolean(cmp == .less));
    } else {
        const cmp = binaryBignumCmpSlow(vm, a_cell, b_cell);
        ctx.replace(vm.tagBoolean(cmp == .less));
    }
}

pub export fn primitive_bignum_lesseq(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b_cell = ctx.pop();
    const a_cell = ctx.peek();
    if (layouts.typeTag(a_cell) == .bignum and layouts.typeTag(b_cell) == .bignum) {
        const cmp = bignum.compare(@ptrFromInt(layouts.UNTAG(a_cell)), @ptrFromInt(layouts.UNTAG(b_cell)));
        ctx.replace(vm.tagBoolean(cmp == .less or cmp == .equal));
    } else {
        const cmp = binaryBignumCmpSlow(vm, a_cell, b_cell);
        ctx.replace(vm.tagBoolean(cmp == .less or cmp == .equal));
    }
}

pub export fn primitive_bignum_greater(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b_cell = ctx.pop();
    const a_cell = ctx.peek();
    if (layouts.typeTag(a_cell) == .bignum and layouts.typeTag(b_cell) == .bignum) {
        const cmp = bignum.compare(@ptrFromInt(layouts.UNTAG(a_cell)), @ptrFromInt(layouts.UNTAG(b_cell)));
        ctx.replace(vm.tagBoolean(cmp == .greater));
    } else {
        const cmp = binaryBignumCmpSlow(vm, a_cell, b_cell);
        ctx.replace(vm.tagBoolean(cmp == .greater));
    }
}

pub export fn primitive_bignum_greatereq(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b_cell = ctx.pop();
    const a_cell = ctx.peek();
    if (layouts.typeTag(a_cell) == .bignum and layouts.typeTag(b_cell) == .bignum) {
        const cmp = bignum.compare(@ptrFromInt(layouts.UNTAG(a_cell)), @ptrFromInt(layouts.UNTAG(b_cell)));
        ctx.replace(vm.tagBoolean(cmp == .greater or cmp == .equal));
    } else {
        const cmp = binaryBignumCmpSlow(vm, a_cell, b_cell);
        ctx.replace(vm.tagBoolean(cmp == .greater or cmp == .equal));
    }
}

pub export fn primitive_bignum_mod(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b_cell = ctx.pop();
    const a_cell = ctx.peek();
    const result = if (layouts.typeTag(a_cell) == .bignum and layouts.typeTag(b_cell) == .bignum)
        bignum.remainder(vm, @ptrFromInt(layouts.UNTAG(a_cell)), @ptrFromInt(layouts.UNTAG(b_cell))) catch vm.memoryError()
    else
        binaryBignumSlow(vm, a_cell, b_cell, bignum.remainder);
    ctx.replace(bignum.maybeToFixnum(result));
}

pub export fn primitive_bignum_gcd(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b_cell = ctx.pop();
    const a_cell = ctx.peek();
    const result = if (layouts.typeTag(a_cell) == .bignum and layouts.typeTag(b_cell) == .bignum)
        bignum.gcd(vm, @ptrFromInt(layouts.UNTAG(a_cell)), @ptrFromInt(layouts.UNTAG(b_cell))) catch vm.memoryError()
    else
        binaryBignumSlow(vm, a_cell, b_cell, bignum.gcd);
    ctx.replace(layouts.tagBignum(result));
}

pub export fn primitive_bignum_bitp(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const bit_cell = ctx.pop();
    const bn_cell = ctx.pop();
    const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(ensureBignumCell(vm, bn_cell)));
    const bit = layouts.untagFixnum(bit_cell);

    if (bit < 0) {
        // Negative bit index: sign extension - return true for negative numbers
        ctx.push(vm.tagBoolean(bn.isNegative()));
        return;
    }

    const result = bignum.testBit(bn, @intCast(bit));
    ctx.push(vm.tagBoolean(result));
}

pub export fn primitive_bignum_log2(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const a_cell = ctx.pop();
    const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(ensureBignumCell(vm, a_cell)));

    const result = bignum.integerLength(bn);
    ctx.push(layouts.tagFixnum(@intCast(result)));
}

// --- Float Arithmetic Primitives ---

pub export fn primitive_float_add(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b = float_mod.untagFloat(ctx.pop());
    const a = float_mod.untagFloat(ctx.peek());
    const boxed = float_mod.allocBoxedFloat(vm, a + b) catch vm.memoryError();
    ctx.replace(layouts.tagFloat(boxed));
}

pub export fn primitive_float_subtract(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b = float_mod.untagFloat(ctx.pop());
    const a = float_mod.untagFloat(ctx.peek());
    const boxed = float_mod.allocBoxedFloat(vm, a - b) catch vm.memoryError();
    ctx.replace(layouts.tagFloat(boxed));
}

pub export fn primitive_float_multiply(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b = float_mod.untagFloat(ctx.pop());
    const a = float_mod.untagFloat(ctx.peek());
    const boxed = float_mod.allocBoxedFloat(vm, a * b) catch vm.memoryError();
    ctx.replace(layouts.tagFloat(boxed));
}

pub export fn primitive_float_divfloat(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const b = float_mod.untagFloat(ctx.pop());
    const a = float_mod.untagFloat(ctx.peek());
    const boxed = float_mod.allocBoxedFloat(vm, a / b) catch vm.memoryError();
    ctx.replace(layouts.tagFloat(boxed));
}

// --- Float Bit Conversion Primitives ---

pub export fn primitive_float_bits(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const float_cell = ctx.peek();
    vm.checkTag(float_cell, .float);

    const boxed: *const layouts.BoxedFloat = @ptrFromInt(layouts.UNTAG(float_cell));
    const f64_val = boxed.n;
    const f32_val: f32 = @floatCast(f64_val);
    const bits: u32 = @bitCast(f32_val);

    // Convert u32 to Factor integer (fixnum or bignum)
    const result = fixnum.fromUnsignedCell(vm, bits);
    ctx.replace(result);
}

pub export fn primitive_bits_float(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const int_cell = ctx.peek();
    const tag = layouts.typeTag(int_cell);

    var bits: u32 = 0;
    if (tag == .fixnum) {
        // Truncate to u32, matching C++: (uint32_t)to_cell(peek())
        // Negative fixnums give valid bit patterns via truncation.
        const fixnum_val = layouts.untagFixnum(int_cell);
        const as_u64: u64 = @bitCast(@as(i64, fixnum_val));
        bits = @truncate(as_u64);
    } else if (tag == .bignum) {
        const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(int_cell));
        var cell_val: u64 = 0;
        const len = bn.length();
        if (len > 0) cell_val = bn.getDigit(0);
        if (bn.isNegative()) cell_val = ~cell_val +% 1;
        bits = @truncate(cell_val);
    } else {
        vm.typeError(.fixnum, int_cell);
    }

    const f32_val: f32 = @bitCast(bits);
    const f64_val: f64 = @floatCast(f32_val);
    const boxed = float_mod.allocBoxedFloat(vm, f64_val) catch vm.memoryError();
    ctx.replace(layouts.tagFloat(boxed));
}

pub export fn primitive_double_bits(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const float_cell = ctx.peek();
    vm.checkTag(float_cell, .float);

    const boxed: *const layouts.BoxedFloat = @ptrFromInt(layouts.UNTAG(float_cell));
    const f64_val = boxed.n;
    const bits: u64 = @bitCast(f64_val);

    // Convert u64 to Factor integer (fixnum or bignum)
    // Check if it fits in a fixnum
    const max_fixnum: Cell = @bitCast(@as(Fixnum, std.math.maxInt(Fixnum) >> @intCast(layouts.tag_bits)));
    if (bits <= max_fixnum) {
        ctx.replace(layouts.tagFixnum(@intCast(bits)));
    } else {
        // Need to create a bignum
        // Determine how many digits needed (1 or 2 on 64-bit)
        const digit_bits = bignum.DIGIT_BITS;
        const digit_mask = bignum.DIGIT_MASK;

        const low_digit = bits & digit_mask;
        const high_digit = bits >> digit_bits;

        const num_digits: Cell = if (high_digit == 0) 1 else 2;
        const bn = allocBignumWithDigit(vm, num_digits, false, low_digit) catch vm.memoryError();

        if (num_digits == 2) {
            bn.setDigit(1, high_digit);
        }

        ctx.replace(layouts.tagBignum(bn));
    }
}

pub export fn primitive_bits_double(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    const int_cell = ctx.peek();
    const tag = layouts.typeTag(int_cell);

    var bits: u64 = 0;
    if (tag == .fixnum) {
        // Cast signed fixnum to u64, preserving bit pattern for negative values.
        // Matches C++: (uint64_t)untag_fixnum(tagged)
        // e.g. -1 → 0xFFFFFFFFFFFFFFFF → NaN double
        const fixnum_val = layouts.untagFixnum(int_cell);
        bits = @bitCast(@as(i64, fixnum_val));
    } else if (tag == .bignum) {
        const bn: *const bignum.Bignum = @ptrFromInt(layouts.UNTAG(int_cell));
        // Extract low 64 bits from bignum magnitude.
        // Matches C++: (uint64_t)bignum_to_uint64(bn)
        const len = bn.length();
        if (len == 0) {
            bits = 0;
        } else if (len == 1) {
            bits = bn.getDigit(0);
        } else {
            // Use low 64 bits for oversized bignums
            const low = bn.getDigit(0);
            const high = bn.getDigit(1);
            bits = (high << bignum.DIGIT_BITS) | low;
        }
        // Handle negative bignums: two's complement
        if (bn.isNegative()) {
            bits = ~bits +% 1;
        }
    } else {
        vm.typeError(.fixnum, int_cell);
    }

    const f64_val: f64 = @bitCast(bits);
    const boxed = float_mod.allocBoxedFloat(vm, f64_val) catch vm.memoryError();
    ctx.replace(layouts.tagFloat(boxed));
}

// --- Float Comparison Primitives ---

pub export fn primitive_float_less(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    const b = float_mod.untagFloat(ctx.pop());
    const a = float_mod.untagFloat(ctx.peek());
    const true_obj = vm_asm.special_objects[@intFromEnum(objects.SpecialObject.canonical_true)];
    ctx.replace(if (a < b) true_obj else layouts.false_object);
}

pub export fn primitive_float_lesseq(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    const b = float_mod.untagFloat(ctx.pop());
    const a = float_mod.untagFloat(ctx.peek());
    const true_obj = vm_asm.special_objects[@intFromEnum(objects.SpecialObject.canonical_true)];
    ctx.replace(if (a <= b) true_obj else layouts.false_object);
}

pub export fn primitive_float_eq(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    const b = float_mod.untagFloat(ctx.pop());
    const a = float_mod.untagFloat(ctx.peek());
    const true_obj = vm_asm.special_objects[@intFromEnum(objects.SpecialObject.canonical_true)];
    ctx.replace(if (a == b) true_obj else layouts.false_object);
}

pub export fn primitive_float_greater(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    const b = float_mod.untagFloat(ctx.pop());
    const a = float_mod.untagFloat(ctx.peek());
    const true_obj = vm_asm.special_objects[@intFromEnum(objects.SpecialObject.canonical_true)];
    ctx.replace(if (a > b) true_obj else layouts.false_object);
}

pub export fn primitive_float_greatereq(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const ctx = vm_asm.ctx;
    const b = float_mod.untagFloat(ctx.pop());
    const a = float_mod.untagFloat(ctx.peek());
    const true_obj = vm_asm.special_objects[@intFromEnum(objects.SpecialObject.canonical_true)];
    ctx.replace(if (a >= b) true_obj else layouts.false_object);
}

// --- Float Formatting ---

// ( n fill width precision format locale -- byte-array )
pub export fn primitive_format_float(vm_asm: *VMAssemblyFields) callconv(.c) void {
    const vm = vm_asm.getVM();
    const ctx = vm_asm.ctx;
    // Pop arguments from stack
    _ = ctx.pop(); // locale
    const format_cell = ctx.pop();
    const precision_cell = ctx.pop();
    const width_cell = ctx.pop();
    _ = ctx.pop(); // fill
    const float_cell = ctx.peek(); // Keep float on stack for now

    // Extract float value
    const value = float_mod.untagFloat(float_cell);

    // Get format string (alien or byte-array)
    const format_bytes: [*]const u8 = vm.alienOffset(format_cell) orelse {
        vm.typeError(.byte_array, format_cell);
    };
    const format_char = format_bytes[0];

    // Get precision and width
    const precision = layouts.untagFixnum(precision_cell);
    const width = layouts.untagFixnum(width_cell);

    // Format the float to a buffer
    // Note: Zig requires compile-time format strings, so we use a switch on precision
    var buf: [256]u8 = undefined;
    const result: []const u8 = blk: {
        const formatted = switch (format_char) {
            'f', 'F' => if (precision >= 0 and precision <= 10) switch (precision) {
                0 => std.fmt.bufPrint(&buf, "{d:.0}", .{value}),
                1 => std.fmt.bufPrint(&buf, "{d:.1}", .{value}),
                2 => std.fmt.bufPrint(&buf, "{d:.2}", .{value}),
                3 => std.fmt.bufPrint(&buf, "{d:.3}", .{value}),
                4 => std.fmt.bufPrint(&buf, "{d:.4}", .{value}),
                5 => std.fmt.bufPrint(&buf, "{d:.5}", .{value}),
                6 => std.fmt.bufPrint(&buf, "{d:.6}", .{value}),
                7 => std.fmt.bufPrint(&buf, "{d:.7}", .{value}),
                8 => std.fmt.bufPrint(&buf, "{d:.8}", .{value}),
                9 => std.fmt.bufPrint(&buf, "{d:.9}", .{value}),
                10 => std.fmt.bufPrint(&buf, "{d:.10}", .{value}),
                else => unreachable,
            } else std.fmt.bufPrint(&buf, "{d}", .{value}),
            'e', 'E' => if (precision >= 0 and precision <= 10) switch (precision) {
                0 => std.fmt.bufPrint(&buf, "{e:.0}", .{value}),
                1 => std.fmt.bufPrint(&buf, "{e:.1}", .{value}),
                2 => std.fmt.bufPrint(&buf, "{e:.2}", .{value}),
                3 => std.fmt.bufPrint(&buf, "{e:.3}", .{value}),
                4 => std.fmt.bufPrint(&buf, "{e:.4}", .{value}),
                5 => std.fmt.bufPrint(&buf, "{e:.5}", .{value}),
                6 => std.fmt.bufPrint(&buf, "{e:.6}", .{value}),
                7 => std.fmt.bufPrint(&buf, "{e:.7}", .{value}),
                8 => std.fmt.bufPrint(&buf, "{e:.8}", .{value}),
                9 => std.fmt.bufPrint(&buf, "{e:.9}", .{value}),
                10 => std.fmt.bufPrint(&buf, "{e:.10}", .{value}),
                else => unreachable,
            } else std.fmt.bufPrint(&buf, "{e}", .{value}),
            else => std.fmt.bufPrint(&buf, "{d}", .{value}),
        };

        break :blk formatted catch {
            ctx.replace(layouts.false_object);
            return;
        };
    };

    // Apply width padding if needed
    const final_result: []const u8 = if (width > 0 and result.len < @as(usize, @intCast(width))) blk2: {
        const pad_len = @as(usize, @intCast(width)) - result.len;
        // Shift result to the right and pad with spaces
        const padded_len = @as(usize, @intCast(width));
        if (padded_len > buf.len) {
            // Width too large for buffer
            ctx.replace(layouts.false_object);
            return;
        }
        // Move existing content to the right
        var i: usize = result.len;
        while (i > 0) : (i -= 1) {
            buf[pad_len + i - 1] = result[i - 1];
        }
        // Fill left with spaces
        for (0..pad_len) |j| {
            buf[j] = ' ';
        }
        break :blk2 buf[0..padded_len];
    } else result;

    // Allocate byte array for result
    const result_len = final_result.len;
    const header_size = @sizeOf(layouts.ByteArray);
    const total_size = header_size + result_len;

    const tagged = vm.allotObject(.byte_array, total_size) orelse {
        vm.memoryError();
    };
    const ba: *layouts.ByteArray = @ptrFromInt(layouts.UNTAG(tagged));
    ba.capacity = layouts.tagFixnum(@intCast(result_len));

    const data = ba.data();
    @memcpy(data[0..result_len], final_result);

    ctx.replace(tagged);
}

// --- Helper Functions ---

fn allocBignumWithDigit(vm: *FactorVM, len: Cell, negative: bool, digit_val: Cell) !*bignum.Bignum {
    const total_size = @sizeOf(bignum.Bignum) + (len + 1) * @sizeOf(Cell);
    const tagged = vm.allotObject(.bignum, total_size) orelse return error.OutOfMemory;
    const bn: *bignum.Bignum = @ptrFromInt(layouts.UNTAG(tagged));
    bn.capacity = layouts.tagFixnum(@intCast(len + 1));
    bn.setNegative(negative);

    if (len > 0) {
        bn.setDigit(0, digit_val);
    }
    for (1..len) |i| {
        bn.setDigit(i, 0);
    }

    return bn;
}
