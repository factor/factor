// bignum.zig - Arbitrary precision integers integrated with the Factor VM.
// Contains shared representation/helpers and VM-facing arithmetic/allocation.

const std = @import("std");
const builtin = @import("builtin");
const layouts = @import("layouts.zig");
const objects = @import("objects.zig");
const Cell = layouts.Cell;
const Fixnum = layouts.Fixnum;

// Native 128÷64 division using x86_64 divq instruction.
// On x86_64, hardware divq divides rdx:rax by a 64-bit operand.
pub inline fn divmod128by64(hi: u64, lo: u64, divisor: u64) struct { q: u64, r: u64 } {
    if (comptime builtin.cpu.arch == .x86_64) {
        var q: u64 = undefined;
        var r: u64 = undefined;
        asm ("divq %[divisor]"
            : [q] "={rax}" (q),
              [r] "={rdx}" (r),
            : [lo] "{rax}" (lo),
              [hi] "{rdx}" (hi),
              [divisor] "r" (divisor),
        );
        return .{ .q = q, .r = r };
    } else {
        const combined: u128 = (@as(u128, hi) << 64) | lo;
        return .{ .q = @intCast(combined / divisor), .r = @intCast(combined % divisor) };
    }
}

// Digit type definitions.
pub const Digit = Cell;
pub const SignedDigit = Fixnum;
pub const TwoDigit = i128;

// Bit width constants.
pub const DIGIT_BITS: u6 = @bitSizeOf(Cell) - 2;

// Radix and masks.
pub const RADIX: Cell = @as(Cell, 1) << DIGIT_BITS;
pub const DIGIT_MASK: Cell = RADIX - 1;

// Half-digit constants for single-digit division specializations.
pub const HALF_DIGIT_BITS: u6 = DIGIT_BITS / 2;
pub const HALF_DIGIT_MASK: Cell = (@as(Cell, 1) << HALF_DIGIT_BITS) - 1;
pub const RADIX_ROOT: Cell = @as(Cell, 1) << HALF_DIGIT_BITS;

pub fn countDigitsUnsigned(value: anytype) Cell {
    if (value == 0) return 0;
    const T = @TypeOf(value);
    const bitlen: Cell = @intCast(@bitSizeOf(T) - @clz(value));
    return (bitlen + DIGIT_BITS - 1) / DIGIT_BITS;
}

pub const Comparison = enum {
    less,
    equal,
    greater,
};

// Bignum structure: header + tagged capacity + sign slot + digits.
pub const Bignum = extern struct {
    const Self = @This();

    header: Cell,
    capacity: Cell, // tagged fixnum = digit_count + 1

    pub const type_number = layouts.TypeTag.bignum;
    pub const element_size = @sizeOf(Cell);

    pub inline fn rawData(self: *const Self) [*]Cell {
        const base: [*]u8 = @ptrCast(@constCast(self));
        return @ptrCast(@alignCast(base + @sizeOf(Bignum)));
    }

    pub inline fn length(self: *const Bignum) Cell {
        return layouts.untagFixnumFast(self.capacity) -| 1;
    }

    pub inline fn rawCapacity(self: *const Bignum) Cell {
        return layouts.untagFixnumFast(self.capacity);
    }

    pub inline fn isNegative(self: *const Bignum) bool {
        std.debug.assert(self.rawCapacity() > 0);
        return self.rawData()[0] != 0;
    }

    pub fn setNegative(self: *Bignum, negative: bool) void {
        self.rawData()[0] = if (negative) 1 else 0;
    }

    pub inline fn isZero(self: *const Bignum) bool {
        return self.length() == 0;
    }

    pub inline fn digits(self: *const Bignum) [*]Cell {
        return self.rawData() + 1;
    }

    pub inline fn getDigit(self: *const Bignum, index: Cell) Cell {
        std.debug.assert(index < self.length());
        return self.digits()[index];
    }

    pub inline fn setDigit(self: *Bignum, index: Cell, value: Cell) void {
        std.debug.assert(index < self.length());
        self.digits()[index] = value;
    }

    pub fn initialize(self: *Bignum, len: Cell, negative: bool) void {
        const obj: *layouts.Object = @ptrCast(self);
        obj.initialize(.bignum);
        self.capacity = layouts.tagFixnum(@intCast(len + 1));
        self.setNegative(negative);
    }
};

// Static bignum values (for common cases).
pub const BIGNUM_ZERO_DATA = [_]Cell{ 0, 0 };
pub const BIGNUM_ONE_POS_DATA = [_]Cell{ 0, 0, 1 };
pub const BIGNUM_ONE_NEG_DATA = [_]Cell{ 0, 1, 1 };

pub const DivisionResult = struct {
    quotient: *Bignum,
    remainder: *Bignum,
};

pub inline fn compareUnsigned(x: *const Bignum, y: *const Bignum) Comparison {
    const x_len = x.length();
    const y_len = y.length();

    if (x_len < y_len) return .less;
    if (x_len > y_len) return .greater;

    const xd = x.digits();
    const yd = y.digits();
    var i: Cell = x_len;
    while (i > 0) {
        i -= 1;
        if (xd[i] < yd[i]) return .less;
        if (xd[i] > yd[i]) return .greater;
    }

    return .equal;
}

pub fn equal(x: *const Bignum, y: *const Bignum) bool {
    if (x == y) return true;
    if (x.isZero()) return y.isZero();
    if (y.isZero()) return false;
    if (x.isNegative() != y.isNegative()) return false;
    return compareUnsigned(x, y) == .equal;
}

pub fn compare(x: *const Bignum, y: *const Bignum) Comparison {
    if (x == y) return .equal;
    if (x.isZero()) {
        if (y.isZero()) return .equal;
        return if (y.isNegative()) .greater else .less;
    }
    if (y.isZero()) {
        return if (x.isNegative()) .less else .greater;
    }

    if (x.isNegative() and !y.isNegative()) return .less;
    if (!x.isNegative() and y.isNegative()) return .greater;

    const mag_cmp = compareUnsigned(x, y);
    if (x.isNegative()) {
        return switch (mag_cmp) {
            .less => .greater,
            .equal => .equal,
            .greater => .less,
        };
    }
    return mag_cmp;
}

// Integer length (number of significant bits).
// Matches C++ bignum_integer_length: (len-1)*DIGIT_BITS + floor(log2(top_digit)).
pub inline fn integerLength(x: *const Bignum) Cell {
    if (x.isZero()) return 0;

    const len = x.length();
    const top_digit = x.getDigit(len - 1);
    if (top_digit == 0) return (len - 1) * DIGIT_BITS;

    return (len - 1) * DIGIT_BITS + @as(Cell, (@bitSizeOf(Cell) - 1) - @clz(top_digit));
}

// VM integration helpers
const vm_mod = @import("vm.zig");
const FactorVM = vm_mod.FactorVM;

inline fn cachedBignum(vm: *FactorVM, which: objects.SpecialObject) ?*Bignum {
    const tagged = vm.vm_asm.special_objects[@intFromEnum(which)];
    if (tagged == layouts.false_object) return null;
    return @ptrFromInt(layouts.UNTAG(tagged));
}

inline fn zeroBignum(vm: *FactorVM) !*Bignum {
    if (cachedBignum(vm, .bignum_zero)) |z| return z;
    return allocBignumZeroed(vm, 0, false);
}

// Convert bignum to fixnum
// Precondition: caller must verify fitsFixnum(bn) first
pub inline fn toFixnum(bn: *const Bignum) Fixnum {
    if (bn.isZero()) return 0;

    const len = bn.length();
    if (len == 1) {
        const result: Cell = bn.getDigit(0);
        return if (bn.isNegative()) @bitCast(0 -% result) else @bitCast(result);
    }
    if (len == 2) {
        const result: Cell = (bn.getDigit(1) << DIGIT_BITS) | bn.getDigit(0);
        return if (bn.isNegative()) @bitCast(0 -% result) else @bitCast(result);
    }

    var result: Cell = 0;

    // Accumulate from high to low order digits
    var i: Cell = len;
    while (i > 0) {
        i -= 1;
        result = (result << DIGIT_BITS) | bn.getDigit(i);
    }

    if (bn.isNegative()) {
        return @bitCast(0 -% result);
    }
    return @bitCast(result);
}

// Check if bignum fits in a fixnum
pub inline fn fitsFixnum(bn: *const Bignum) bool {
    const len = bn.length();
    if (len == 0) return true;
    if (len > 1) return false;

    const digit = bn.getDigit(0);
    const max_fixnum: Cell = @bitCast(@as(Fixnum, std.math.maxInt(Fixnum) >> @intCast(layouts.tag_bits)));

    if (bn.isNegative()) {
        // Min fixnum is -(max_fixnum + 1)
        return digit <= max_fixnum + 1;
    }
    return digit <= max_fixnum;
}

// Returns a tagged value - either a fixnum if it fits, or the bignum pointer tagged
pub inline fn maybeToFixnum(bn: *const Bignum) Cell {
    if (fitsFixnum(bn)) {
        return layouts.tagFixnum(toFixnum(bn));
    }
    return layouts.tagBignum(@constCast(bn));
}

// Allocate bignum in VM nursery
pub inline fn allocBignum(vm: *FactorVM, len: Cell, negative: bool) !*Bignum {
    const total_size = @sizeOf(Bignum) + (len + 1) * @sizeOf(Cell);
    const tagged = vm.allotObject(.bignum, total_size) orelse return error.OutOfMemory;
    const bn: *Bignum = @ptrFromInt(layouts.UNTAG(tagged));
    bn.initialize(len, negative);
    return bn;
}

// Allocate zeroed bignum in VM nursery
pub fn allocBignumZeroed(vm: *FactorVM, len: Cell, negative: bool) !*Bignum {
    const bn = try allocBignum(vm, len, negative);
    @memset(bn.digits()[0..len], 0);
    return bn;
}

// Create bignum from signed 64-bit integer (VM version)
pub fn fromInt64(vm: *FactorVM, n: i64) !*Bignum {
    if (n == 0) {
        return zeroBignum(vm);
    }

    const negative = n < 0;
    const abs_n: u64 = if (negative) @bitCast(-%n) else @bitCast(n);

    if (abs_n < RADIX) {
        const bn = try allocBignum(vm, 1, negative);
        bn.setDigit(0, abs_n & DIGIT_MASK);
        return bn;
    }

    const count: Cell = countDigitsUnsigned(abs_n);

    const bn = try allocBignum(vm, count, negative);
    var val = abs_n;
    var i: Cell = 0;
    while (val != 0) : (i += 1) {
        bn.setDigit(i, val & DIGIT_MASK);
        val >>= DIGIT_BITS;
    }
    return bn;
}

// Create bignum from unsigned 64-bit integer (VM version)
pub fn fromUint64(vm: *FactorVM, n: u64) !*Bignum {
    if (n == 0) {
        return zeroBignum(vm);
    }

    if (n < RADIX) {
        const bn = try allocBignum(vm, 1, false);
        bn.setDigit(0, n & DIGIT_MASK);
        return bn;
    }

    const count: Cell = countDigitsUnsigned(n);

    const bn = try allocBignum(vm, count, false);
    var val = n;
    var i: Cell = 0;
    while (val != 0) : (i += 1) {
        bn.setDigit(i, val & DIGIT_MASK);
        val >>= DIGIT_BITS;
    }
    return bn;
}

// Convert bignum to signed 64-bit integer (may overflow)
pub fn toInt64(bn: *const Bignum) i64 {
    if (bn.isZero()) return 0;

    const len = bn.length();
    if (len == 1) {
        const result: u64 = @intCast(bn.getDigit(0));
        return if (bn.isNegative()) -%@as(i64, @bitCast(result)) else @bitCast(result);
    }
    if (len == 2) {
        const lo: u64 = @intCast(bn.getDigit(0));
        const hi: u64 = @intCast(bn.getDigit(1));
        const result: u64 = (hi << DIGIT_BITS) | lo;
        return if (bn.isNegative()) -%@as(i64, @bitCast(result)) else @bitCast(result);
    }

    var result: u64 = 0;

    var i: Cell = len;
    while (i > 0) {
        i -= 1;
        result = (result << DIGIT_BITS) | bn.getDigit(i);
    }

    if (bn.isNegative()) {
        return -%@as(i64, @bitCast(result));
    }
    return @bitCast(result);
}

// Convert bignum to unsigned 64-bit integer (may overflow)
pub fn toUint64(bn: *const Bignum) u64 {
    if (bn.isZero()) return 0;

    const len = bn.length();
    if (len == 1) {
        return @intCast(bn.getDigit(0));
    }
    if (len == 2) {
        const lo: u64 = @intCast(bn.getDigit(0));
        const hi: u64 = @intCast(bn.getDigit(1));
        return (hi << DIGIT_BITS) | lo;
    }

    var result: u64 = 0;

    var i: Cell = len;
    while (i > 0) {
        i -= 1;
        result = (result << DIGIT_BITS) | bn.getDigit(i);
    }

    return result;
}

// Create bignum from fixnum using VM nursery
pub fn fromFixnum(vm: *FactorVM, n: Fixnum) !*Bignum {
    if (n == 0) {
        return zeroBignum(vm);
    }

    const negative = n < 0;
    var abs_n: Cell = if (negative) @bitCast(-n) else @bitCast(n);

    if (abs_n < RADIX) {
        // Single digit
        const bn = try allocBignum(vm, 1, negative);
        bn.setDigit(0, abs_n & DIGIT_MASK);
        return bn;
    }

    // Count digits needed
    const count: Cell = countDigitsUnsigned(abs_n);

    const bn = try allocBignum(vm, count, negative);
    var i: Cell = 0;
    while (abs_n != 0) : (i += 1) {
        bn.setDigit(i, abs_n & DIGIT_MASK);
        abs_n >>= DIGIT_BITS;
    }

    return bn;
}

// Create bignum from unsigned cell using VM nursery
pub fn fromCell(vm: *FactorVM, n: Cell) !*Bignum {
    if (n == 0) {
        return zeroBignum(vm);
    }

    if (n < RADIX) {
        const bn = try allocBignum(vm, 1, false);
        bn.setDigit(0, n & DIGIT_MASK);
        return bn;
    }

    const count: Cell = countDigitsUnsigned(n);

    const bn = try allocBignum(vm, count, false);
    var val = n;
    var i: Cell = 0;
    while (val != 0) : (i += 1) {
        bn.setDigit(i, val & DIGIT_MASK);
        val >>= DIGIT_BITS;
    }

    return bn;
}

// Convert bignum to cell (unsigned, may overflow)
pub fn toCell(bn: *const Bignum) Cell {
    if (bn.isZero()) return 0;

    const len = bn.length();
    if (len == 1) {
        return bn.getDigit(0);
    }
    if (len == 2) {
        return (bn.getDigit(1) << DIGIT_BITS) | bn.getDigit(0);
    }

    var result: Cell = 0;

    var i: Cell = len;
    while (i > 0) {
        i -= 1;
        result = (result << DIGIT_BITS) | bn.getDigit(i);
    }

    return result;
}

// Bignum arithmetic using VM nursery allocation
pub fn add(vm: *FactorVM, x: *const Bignum, y: *const Bignum) !*Bignum {
    // Return the other operand directly when one is zero (matching C++)
    if (x.isZero()) return @constCast(y);
    if (y.isZero()) return @constCast(x);

    // Same sign: add magnitudes
    if (x.isNegative() == y.isNegative()) {
        return addUnsigned(vm, x, y, x.isNegative());
    }

    // Different signs: subtract magnitudes
    const cmp = compareUnsigned(x, y);
    return switch (cmp) {
        .equal => zeroBignum(vm),
        .less => subtractUnsigned(vm, y, x, y.isNegative()),
        .greater => subtractUnsigned(vm, x, y, x.isNegative()),
    };
}

pub fn subtract(vm: *FactorVM, x: *const Bignum, y: *const Bignum) !*Bignum {
    if (y.isZero()) return @constCast(x);
    if (x.isZero()) return negateBignum(vm, y);

    // Different signs: add magnitudes
    if (x.isNegative() != y.isNegative()) {
        return addUnsigned(vm, x, y, x.isNegative());
    }

    // Same sign: subtract magnitudes
    const cmp = compareUnsigned(x, y);
    return switch (cmp) {
        .equal => zeroBignum(vm),
        .less => subtractUnsigned(vm, y, x, !x.isNegative()),
        .greater => subtractUnsigned(vm, x, y, x.isNegative()),
    };
}

pub fn multiply(vm: *FactorVM, x: *const Bignum, y: *const Bignum) !*Bignum {
    if (x == y) {
        return square(vm, x);
    }
    if (x.isZero() or y.isZero()) {
        return zeroBignum(vm);
    }

    const x_len = x.length();
    const y_len = y.length();

    // Check for multiplication by 1 or -1
    if (x_len == 1 and x.getDigit(0) == 1) {
        if (x.isNegative()) {
            return negateBignum(vm, y);
        }
        return @constCast(y);
    }
    if (y_len == 1 and y.getDigit(0) == 1) {
        if (y.isNegative()) {
            return negateBignum(vm, x);
        }
        return @constCast(x);
    }

    const result_negative = x.isNegative() != y.isNegative();

    // Fast path: single-digit multiplier (O(n) instead of O(n²))
    if (y_len == 1) {
        return multiplyBySingleDigitVM(vm, x, y.getDigit(0), result_negative);
    }
    if (x_len == 1) {
        return multiplyBySingleDigitVM(vm, y, x.getDigit(0), result_negative);
    }

    return try multiplyUnsigned(vm, x, y, result_negative);
}

// Square - optimized multiplication by self (VM version)
pub fn square(vm: *FactorVM, x_in: *const Bignum) !*Bignum {
    if (x_in.isZero()) {
        return zeroBignum(vm);
    }

    // Root x to protect from GC during allocation
    var x_cell: Cell = layouts.tagBignum(@constCast(x_in));
    vm.data_roots.append(vm.allocator, &x_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    const length = x_in.length();
    const z = try allocBignumZeroed(vm, length + length, false);

    // Re-derive x after potential GC
    const x: *const Bignum = @ptrFromInt(layouts.UNTAG(x_cell));
    const x_digits = x.digits()[0..length];
    const z_digits = z.digits()[0 .. length + length];

    const scratch_size = karatsubaScratchSize(length);
    var empty = [_]Cell{};
    const scratch = if (scratch_size > 0)
        vm.allocator.alloc(Cell, scratch_size) catch return error.OutOfMemory
    else
        empty[0..];
    defer if (scratch_size > 0) vm.allocator.free(scratch);
    if (scratch_size > 0) @memset(scratch, 0);
    squareDigits(x_digits, z_digits, scratch);

    return trim(vm, z);
}

pub fn quotient(vm: *FactorVM, numerator: *const Bignum, denominator: *const Bignum) !*Bignum {
    if (denominator.isZero()) {
        return error.DivisionByZero;
    }
    if (numerator.isZero()) {
        return zeroBignum(vm);
    }

    const q_negative = numerator.isNegative() != denominator.isNegative();
    const cmp = compareUnsigned(numerator, denominator);
    return switch (cmp) {
        .equal => allocBignumWithDigit(vm, 1, q_negative, 1),
        .less => zeroBignum(vm),
        .greater => if (denominator.length() == 1)
            // Single-digit: quotient-only path skips remainder allocation
            divideBySingleDigitQuotientOnly(vm, numerator, denominator.getDigit(0), q_negative)
        else
            divideKnuthQuotientOnly(vm, numerator, denominator, q_negative),
    };
}

pub fn divmod(vm: *FactorVM, numerator: *const Bignum, denominator: *const Bignum) !DivisionResult {
    if (denominator.isZero()) {
        return error.DivisionByZero;
    }

    if (numerator.isZero()) {
        const q = try zeroBignum(vm);
        var q_cell: Cell = layouts.tagBignum(q);
        vm.data_roots.append(vm.allocator, &q_cell) catch return error.OutOfMemory;
        defer _ = vm.data_roots.pop();
        const r = try zeroBignum(vm);
        return .{
            .quotient = @ptrFromInt(layouts.UNTAG(q_cell)),
            .remainder = r,
        };
    }

    // Root inputs for the .less and .greater cases
    var num_cell: Cell = layouts.tagBignum(@constCast(numerator));
    var den_cell: Cell = layouts.tagBignum(@constCast(denominator));
    vm.data_roots.ensureUnusedCapacity(vm.allocator, 2) catch return error.OutOfMemory;
    vm.data_roots.appendAssumeCapacity(&num_cell);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&den_cell);
    defer _ = vm.data_roots.pop();

    const q_negative = numerator.isNegative() != denominator.isNegative();
    const r_negative = numerator.isNegative();

    const cmp = compareUnsigned(numerator, denominator);
    return switch (cmp) {
        .equal => blk: {
            const q = try allocBignumWithDigit(vm, 1, q_negative, 1);
            var q_cell: Cell = layouts.tagBignum(q);
            vm.data_roots.append(vm.allocator, &q_cell) catch return error.OutOfMemory;
            defer _ = vm.data_roots.pop();
            const r = try zeroBignum(vm);
            break :blk .{
                .quotient = @ptrFromInt(layouts.UNTAG(q_cell)),
                .remainder = r,
            };
        },
        .less => blk: {
            const q = try zeroBignum(vm);
            var q_cell: Cell = layouts.tagBignum(q);
            vm.data_roots.append(vm.allocator, &q_cell) catch return error.OutOfMemory;
            defer _ = vm.data_roots.pop();
            const num: *const Bignum = @ptrFromInt(layouts.UNTAG(num_cell));
            const r = try copyBignumWithSign(vm, num, r_negative);
            break :blk .{
                .quotient = @ptrFromInt(layouts.UNTAG(q_cell)),
                .remainder = r,
            };
        },
        .greater => blk: {
            const num: *const Bignum = @ptrFromInt(layouts.UNTAG(num_cell));
            const den: *const Bignum = @ptrFromInt(layouts.UNTAG(den_cell));
            break :blk try divideUnsigned(vm, num, den, q_negative, r_negative);
        },
    };
}

pub fn shift(vm: *FactorVM, x: *const Bignum, shift_amt: Fixnum) !*Bignum {
    if (x.isZero() or shift_amt == 0) {
        return @constCast(x);
    }

    if (shift_amt > 0) {
        return shiftLeft(vm, x, @intCast(shift_amt));
    } else {
        // Arithmetic right shift for negative numbers:
        // ash(x, -n) = ~(magnitude_shift(~x, -n)) per C++ bignum_arithmetic_shift
        if (x.isNegative()) {
            const not_x = try bitNot(vm, x);
            const shifted = try shiftRight(vm, not_x, @intCast(-shift_amt));
            return bitNot(vm, shifted);
        }
        return shiftRight(vm, x, @intCast(-shift_amt));
    }
}

// Bignum bitwise operations. Sign-case routing is identical for all three
// ops, so we unify into a single comptime-parameterized entry point.
fn bitwiseOp(vm: *FactorVM, x: *const Bignum, y: *const Bignum, comptime op: BitwiseOp) !*Bignum {
    if (!x.isNegative() and !y.isNegative()) {
        return bignumPosPosOp(vm, x, y, op);
    }
    if (x.isNegative() and y.isNegative()) {
        return bignumNegNegOp(vm, x, y, op);
    }
    // One positive, one negative — positive arg must be first
    if (x.isNegative()) {
        return bignumPosNegOp(vm, y, x, op);
    }
    return bignumPosNegOp(vm, x, y, op);
}

pub fn bitAnd(vm: *FactorVM, x: *const Bignum, y: *const Bignum) !*Bignum {
    return bitwiseOp(vm, x, y, .and_op);
}

pub fn bitOr(vm: *FactorVM, x: *const Bignum, y: *const Bignum) !*Bignum {
    return bitwiseOp(vm, x, y, .or_op);
}

pub fn bitXor(vm: *FactorVM, x: *const Bignum, y: *const Bignum) !*Bignum {
    return bitwiseOp(vm, x, y, .xor_op);
}

const BitwiseOp = enum { and_op, or_op, xor_op };

// Positive-positive bitwise op with direct nursery allocation.
// Matches C++ bignum_pospos_bitwise_op: allocates result in GC heap,
// does digit-wise operation in place. No malloc/free intermediate.
inline fn bignumPosPosOp(vm: *FactorVM, x_in: *const Bignum, y_in: *const Bignum, comptime op: BitwiseOp) !*Bignum {
    if (x_in.isZero()) {
        return switch (op) {
            .and_op => zeroBignum(vm),
            .or_op, .xor_op => copyBignum(vm, y_in),
        };
    }
    if (y_in.isZero()) {
        return switch (op) {
            .and_op => zeroBignum(vm),
            .or_op, .xor_op => copyBignum(vm, x_in),
        };
    }

    // Root both inputs — allocBignum can trigger GC
    var x_cell: Cell = layouts.tagBignum(@constCast(x_in));
    var y_cell: Cell = layouts.tagBignum(@constCast(y_in));
    vm.data_roots.ensureUnusedCapacity(vm.allocator, 2) catch return error.OutOfMemory;
    vm.data_roots.appendAssumeCapacity(&x_cell);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&y_cell);
    defer _ = vm.data_roots.pop();

    const x_len = x_in.length();
    const y_len = y_in.length();
    // AND result can't exceed the shorter operand; OR/XOR need the longer
    const alloc_len = switch (op) {
        .and_op => @min(x_len, y_len),
        .or_op, .xor_op => @max(x_len, y_len),
    };

    // Allocate result directly in nursery (may trigger GC)
    const bn = try allocBignum(vm, alloc_len, false);

    // Re-derive pointers after potential GC, pre-compute digit slices
    const x: *const Bignum = @ptrFromInt(layouts.UNTAG(x_cell));
    const y: *const Bignum = @ptrFromInt(layouts.UNTAG(y_cell));
    const xl = x.length();
    const yl = y.length();
    const x_digits = x.digits();
    const y_digits = y.digits();
    const r_digits = bn.digits();
    const min_len = @min(xl, yl);

    // Phase 1: both operands have digits
    for (0..min_len) |i| {
        r_digits[i] = switch (op) {
            .and_op => x_digits[i] & y_digits[i],
            .or_op => x_digits[i] | y_digits[i],
            .xor_op => x_digits[i] ^ y_digits[i],
        };
    }

    // Phase 2: only the longer operand has digits (AND doesn't need this)
    if (op != .and_op) {
        const max_len = @max(xl, yl);
        if (xl > yl) {
            @memcpy(r_digits[min_len..max_len], x_digits[min_len..max_len]);
        } else if (yl > xl) {
            @memcpy(r_digits[min_len..max_len], y_digits[min_len..max_len]);
        }
    }

    // Trim leading zero digits, matching C++ bignum_trim call
    return trim(vm, bn);
}

// Positive-negative bitwise op with direct nursery allocation.
// arg1 is positive, arg2 is negative. Matches C++ bignum_posneg_bitwise_op.
// Converts arg2 to two's complement on the fly, no intermediate malloc.
fn bignumPosNegOp(vm: *FactorVM, arg1_in: *const Bignum, arg2_in: *const Bignum, comptime op: BitwiseOp) !*Bignum {
    std.debug.assert(!arg1_in.isNegative() and arg2_in.isNegative());

    // Root both inputs
    var arg1_cell: Cell = layouts.tagBignum(@constCast(arg1_in));
    var arg2_cell: Cell = layouts.tagBignum(@constCast(arg2_in));
    vm.data_roots.ensureUnusedCapacity(vm.allocator, 2) catch return error.OutOfMemory;
    vm.data_roots.appendAssumeCapacity(&arg1_cell);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&arg2_cell);
    defer _ = vm.data_roots.pop();

    const arg1_len = arg1_in.length();
    const arg2_len = arg2_in.length();
    // Result is negative for OR and XOR (matches C++)
    const neg_p = (op == .or_op or op == .xor_op);
    const max_len = if (arg1_len > arg2_len + 1) arg1_len else arg2_len + 1;

    const bn = try allocBignum(vm, max_len, neg_p);

    // Re-derive after potential GC, pre-compute digit slices
    const arg1: *const Bignum = @ptrFromInt(layouts.UNTAG(arg1_cell));
    const arg2: *const Bignum = @ptrFromInt(layouts.UNTAG(arg2_cell));
    const a1_len = arg1.length();
    const a2_len = arg2.length();
    const a1_digits = arg1.digits();
    const a2_digits = arg2.digits();
    const r_digits = bn.digits();

    // Convert arg2 from sign-magnitude to two's complement on the fly.
    // Two's complement: ~digit & MASK + carry. Once carry drops to 0
    // (typically after 1-2 digits), the conversion simplifies to just
    // ~digit & MASK with no carry branch, so we split into two loops.
    var i: usize = 0;
    var carry2: Cell = 1;

    // Phase 1: carry is live (typically 1-2 iterations)
    while (i < max_len and carry2 != 0) : (i += 1) {
        const digit1: Cell = if (i < a1_len) a1_digits[i] else 0;
        const raw_digit2: Cell = if (i < a2_len) a2_digits[i] else 0;
        var digit2: Cell = ((~raw_digit2) & DIGIT_MASK) +% 1;
        if (digit2 < RADIX) {
            carry2 = 0;
        } else {
            digit2 = digit2 -% RADIX;
        }
        r_digits[i] = switch (op) {
            .and_op => digit1 & digit2,
            .or_op => digit1 | digit2,
            .xor_op => digit1 ^ digit2,
        };
    }

    // Phase 2: carry is dead — branch-free inversion
    while (i < max_len) : (i += 1) {
        const digit1: Cell = if (i < a1_len) a1_digits[i] else 0;
        const raw_digit2: Cell = if (i < a2_len) a2_digits[i] else 0;
        const digit2: Cell = (~raw_digit2) & DIGIT_MASK;
        r_digits[i] = switch (op) {
            .and_op => digit1 & digit2,
            .or_op => digit1 | digit2,
            .xor_op => digit1 ^ digit2,
        };
    }

    // If result is negative, convert back from two's complement to sign-magnitude
    if (neg_p) {
        negateMagnitude(bn);
    }

    return trim(vm, bn);
}

// Negative-negative bitwise op with direct nursery allocation.
// Both args are negative. Matches C++ bignum_negneg_bitwise_op.
fn bignumNegNegOp(vm: *FactorVM, arg1_in: *const Bignum, arg2_in: *const Bignum, comptime op: BitwiseOp) !*Bignum {
    std.debug.assert(arg1_in.isNegative() and arg2_in.isNegative());

    // Root both inputs
    var arg1_cell: Cell = layouts.tagBignum(@constCast(arg1_in));
    var arg2_cell: Cell = layouts.tagBignum(@constCast(arg2_in));
    vm.data_roots.ensureUnusedCapacity(vm.allocator, 2) catch return error.OutOfMemory;
    vm.data_roots.appendAssumeCapacity(&arg1_cell);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&arg2_cell);
    defer _ = vm.data_roots.pop();

    const arg1_len = arg1_in.length();
    const arg2_len = arg2_in.length();
    // Result is negative for AND and OR (matches C++)
    const neg_p = (op == .and_op or op == .or_op);
    const max_len = (if (arg1_len > arg2_len) arg1_len else arg2_len) + 1;

    const bn = try allocBignum(vm, max_len, neg_p);

    // Re-derive after potential GC, pre-compute digit slices
    const arg1: *const Bignum = @ptrFromInt(layouts.UNTAG(arg1_cell));
    const arg2: *const Bignum = @ptrFromInt(layouts.UNTAG(arg2_cell));
    const a1_len = arg1.length();
    const a2_len = arg2.length();
    const a1_digits = arg1.digits();
    const a2_digits = arg2.digits();
    const r_digits = bn.digits();

    // Convert both args from sign-magnitude to two's complement on the fly.
    // Split into phases based on carry state to eliminate branches once
    // carries settle (typically after 1-2 digits each).
    var i: usize = 0;
    var carry1: Cell = 1;
    var carry2: Cell = 1;

    // Phase 1: both carries live
    while (i < max_len and (carry1 | carry2) != 0) : (i += 1) {
        const raw_digit1: Cell = if (i < a1_len) a1_digits[i] else 0;
        var digit1: Cell = ((~raw_digit1) & DIGIT_MASK) +% carry1;
        if (digit1 < RADIX) {
            carry1 = 0;
        } else {
            digit1 = digit1 -% RADIX;
        }
        const raw_digit2: Cell = if (i < a2_len) a2_digits[i] else 0;
        var digit2: Cell = ((~raw_digit2) & DIGIT_MASK) +% carry2;
        if (digit2 < RADIX) {
            carry2 = 0;
        } else {
            digit2 = digit2 -% RADIX;
        }
        r_digits[i] = switch (op) {
            .and_op => digit1 & digit2,
            .or_op => digit1 | digit2,
            .xor_op => digit1 ^ digit2,
        };
    }

    // Phase 2: both carries dead — branch-free inversion
    while (i < max_len) : (i += 1) {
        const raw_digit1: Cell = if (i < a1_len) a1_digits[i] else 0;
        const digit1: Cell = (~raw_digit1) & DIGIT_MASK;
        const raw_digit2: Cell = if (i < a2_len) a2_digits[i] else 0;
        const digit2: Cell = (~raw_digit2) & DIGIT_MASK;
        r_digits[i] = switch (op) {
            .and_op => digit1 & digit2,
            .or_op => digit1 | digit2,
            .xor_op => digit1 ^ digit2,
        };
    }

    // If result is negative, convert back from two's complement to sign-magnitude
    if (neg_p) {
        negateMagnitude(bn);
    }

    return trim(vm, bn);
}

// Negate magnitude in place (two's complement conversion).
// Matches C++ bignum_negate_magnitude.
fn negateMagnitude(arg: *Bignum) void {
    const len = arg.length();
    const d = arg.digits();
    var carry: Cell = 1;
    for (0..len) |i| {
        var digit: Cell = ((~d[i]) & DIGIT_MASK) +% carry;
        if (digit < RADIX) {
            carry = 0;
        } else {
            digit = digit -% RADIX;
            carry = 1;
        }
        d[i] = digit;
    }
}

// Bignum bitwise NOT: ~x = -(x+1)
// Direct nursery allocation, no BignumOps intermediate.
pub fn bitNot(vm: *FactorVM, x: *const Bignum) !*Bignum {
    if (x.isZero()) {
        // ~0 = -1
        return allocBignumWithDigit(vm, 1, true, 1);
    }
    if (x.isNegative()) {
        // ~(-n) = n - 1: subtract 1 from magnitude, result positive
        return subtractOneMagnitude(vm, x, false);
    } else {
        // ~n = -(n + 1): add 1 to magnitude, result negative
        return addOneMagnitude(vm, x, true);
    }
}

// Add 1 to magnitude of x, set sign. Result allocated in nursery.
fn addOneMagnitude(vm: *FactorVM, x_in: *const Bignum, negative: bool) !*Bignum {
    var x_cell: Cell = layouts.tagBignum(@constCast(x_in));
    vm.data_roots.append(vm.allocator, &x_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    const x_len = x_in.length();
    const r = try allocBignum(vm, x_len, negative);
    const x: *const Bignum = @ptrFromInt(layouts.UNTAG(x_cell));

    var carry: Cell = 1;
    for (0..x_len) |i| {
        const sum = x.getDigit(i) + carry;
        r.setDigit(i, sum & DIGIT_MASK);
        carry = sum >> DIGIT_BITS;
    }

    if (carry != 0) {
        var r_cell: Cell = layouts.tagBignum(r);
        vm.data_roots.append(vm.allocator, &r_cell) catch return error.OutOfMemory;
        defer _ = vm.data_roots.pop();
        const r2 = try allocBignum(vm, x_len + 1, negative);
        const rr: *const Bignum = @ptrFromInt(layouts.UNTAG(r_cell));
        @memcpy(r2.digits()[0..x_len], rr.digits()[0..x_len]);
        r2.setDigit(x_len, carry);
        return r2;
    }
    return r;
}

// Subtract 1 from magnitude of x, set sign. Result allocated in nursery.
// Precondition: x is not zero (caller must check).
fn subtractOneMagnitude(vm: *FactorVM, x_in: *const Bignum, negative: bool) !*Bignum {
    var x_cell: Cell = layouts.tagBignum(@constCast(x_in));
    vm.data_roots.append(vm.allocator, &x_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    const x_len = x_in.length();
    const r = try allocBignum(vm, x_len, negative);
    const x: *const Bignum = @ptrFromInt(layouts.UNTAG(x_cell));

    var borrow: Cell = 1;
    for (0..x_len) |i| {
        const d = x.getDigit(i);
        if (d >= borrow) {
            r.setDigit(i, d - borrow);
            borrow = 0;
        } else {
            r.setDigit(i, (d +% RADIX -% borrow) & DIGIT_MASK);
            borrow = 1;
        }
    }
    std.debug.assert(borrow == 0);
    return trim(vm, r);
}

// Bignum remainder (modulo)
// Uses divmod (nursery allocation) directly, no BignumOps intermediate.
pub fn remainder(vm: *FactorVM, numerator: *const Bignum, denominator: *const Bignum) !*Bignum {
    if (denominator.isZero()) {
        return error.DivisionByZero;
    }
    if (numerator.isZero()) {
        return @constCast(numerator);
    }

    const r_negative = numerator.isNegative();
    const cmp = compareUnsigned(numerator, denominator);
    return switch (cmp) {
        .equal => zeroBignum(vm),
        .less => @constCast(numerator),
        .greater => blk: {
            if (denominator.length() == 1) {
                const d = denominator.getDigit(0);
                if (d == 1) break :blk zeroBignum(vm);
                break :blk divideBySingleDigitRemainderOnly(vm, numerator, d, r_negative);
            }
            break :blk divideKnuthRemainderOnly(vm, numerator, denominator, r_negative);
        },
    };
}

inline fn setUnsignedLength(bn: *Bignum, len: Cell) void {
    bn.capacity = layouts.tagFixnum(@as(Fixnum, @intCast(len + 1)));
    bn.setNegative(false);
}

// Bignum GCD (greatest common divisor)
pub fn gcd(vm: *FactorVM, a: *const Bignum, b: *const Bignum) !*Bignum {
    if (a.isZero()) return abs(vm, b);
    if (b.isZero()) return abs(vm, a);

    // Lehmer/hybrid GCD (matches C++ VM non-Win64 path):
    // keep working values in-place and use occasional Euclidean remainder steps.
    // Root b before first copy to protect it from GC during allocation.
    vm.data_roots.ensureUnusedCapacity(vm.allocator, 3) catch return error.OutOfMemory;
    var b_root: Cell = layouts.tagBignum(@constCast(b));
    vm.data_roots.appendAssumeCapacity(&b_root);
    defer _ = vm.data_roots.pop();
    var a_cell: Cell = layouts.tagBignum(try copyBignumWithSign(vm, a, false));
    vm.data_roots.appendAssumeCapacity(&a_cell);
    defer _ = vm.data_roots.pop();
    var b_cell: Cell = layouts.tagBignum(try copyBignumWithSign(vm, @ptrFromInt(layouts.UNTAG(b_root)), false));
    vm.data_roots.appendAssumeCapacity(&b_cell);
    defer _ = vm.data_roots.pop();

    var a_bn: *Bignum = @ptrFromInt(layouts.UNTAG(a_cell));
    var b_bn: *Bignum = @ptrFromInt(layouts.UNTAG(b_cell));
    var size_a: Cell = a_bn.length();
    var size_b: Cell = b_bn.length();

    if (compareUnsigned(a_bn, b_bn) == .less) {
        const tmp = a_cell;
        a_cell = b_cell;
        b_cell = tmp;
        const tmp_size = size_a;
        size_a = size_b;
        size_b = tmp_size;
    }

    while (size_a > 1) {
        a_bn = @ptrFromInt(layouts.UNTAG(a_cell));
        b_bn = @ptrFromInt(layouts.UNTAG(b_cell));
        const a_digits = a_bn.digits();
        const b_digits = b_bn.digits();

        const top_a = a_digits[size_a - 1];
        const nbits: u6 = @intCast((@bitSizeOf(Cell) - 1) - @clz(top_a));
        const shift_left: u7 = @intCast(DIGIT_BITS - nbits);

        var x: TwoDigit = (@as(TwoDigit, @intCast(a_digits[size_a - 1])) << shift_left) |
            @as(TwoDigit, @intCast(a_digits[size_a - 2] >> nbits));
        var y: TwoDigit = 0;
        if (size_b >= size_a - 1) {
            y |= @as(TwoDigit, @intCast(b_digits[size_a - 2] >> nbits));
        }
        if (size_b >= size_a) {
            y |= @as(TwoDigit, @intCast(b_digits[size_a - 1])) << shift_left;
        }

        var A: TwoDigit = 1;
        var B: TwoDigit = 0;
        var C: TwoDigit = 0;
        var D: TwoDigit = 1;
        var k: usize = 0;
        while (true) : (k += 1) {
            const yc = y - C;
            if (yc == 0) break;

            const q = @divTrunc(x + (A - 1), yc);
            const s = B + (q * D);
            const t = x - (q * y);
            if (s > t) break;

            x = y;
            y = t;

            const t2 = A + (q * C);
            A = D;
            B = C;
            C = s;
            D = t2;
        }

        if (k == 0) {
            if (size_b == 0) {
                setUnsignedLength(a_bn, size_a);
                return a_bn;
            }

            const rem = try remainder(vm, a_bn, b_bn);

            a_bn = @ptrFromInt(layouts.UNTAG(a_cell));
            b_bn = @ptrFromInt(layouts.UNTAG(b_cell));
            const a_mut = a_bn.digits();
            const b_mut = b_bn.digits();

            @memcpy(a_mut[0..size_b], b_mut[0..size_b]);
            size_a = size_b;
            setUnsignedLength(a_bn, size_a);

            const rem_len = rem.length();
            @memcpy(b_mut[0..rem_len], rem.digits()[0..rem_len]);
            size_b = rem_len;
            setUnsignedLength(b_bn, size_b);
            continue;
        }

        a_bn = @ptrFromInt(layouts.UNTAG(a_cell));
        b_bn = @ptrFromInt(layouts.UNTAG(b_cell));
        const a_mut = a_bn.digits();
        const b_mut = b_bn.digits();

        var s: TwoDigit = 0;
        var t: TwoDigit = 0;
        var i: Cell = 0;

        if ((k & 1) == 1) {
            while (i < size_b) : (i += 1) {
                const ai = @as(TwoDigit, @intCast(a_mut[i]));
                const bi = @as(TwoDigit, @intCast(b_mut[i]));
                s += (A * bi) - (B * ai);
                t += (D * ai) - (C * bi);
                a_mut[i] = @intCast(@as(u128, @bitCast(s)) & DIGIT_MASK);
                b_mut[i] = @intCast(@as(u128, @bitCast(t)) & DIGIT_MASK);
                s >>= DIGIT_BITS;
                t >>= DIGIT_BITS;
            }
            while (i < size_a) : (i += 1) {
                const ai = @as(TwoDigit, @intCast(a_mut[i]));
                s -= B * ai;
                t += D * ai;
                a_mut[i] = @intCast(@as(u128, @bitCast(s)) & DIGIT_MASK);
                s >>= DIGIT_BITS;
                t >>= DIGIT_BITS;
            }
        } else {
            while (i < size_b) : (i += 1) {
                const ai = @as(TwoDigit, @intCast(a_mut[i]));
                const bi = @as(TwoDigit, @intCast(b_mut[i]));
                s += (A * ai) - (B * bi);
                t += (D * bi) - (C * ai);
                a_mut[i] = @intCast(@as(u128, @bitCast(s)) & DIGIT_MASK);
                b_mut[i] = @intCast(@as(u128, @bitCast(t)) & DIGIT_MASK);
                s >>= DIGIT_BITS;
                t >>= DIGIT_BITS;
            }
            while (i < size_a) : (i += 1) {
                const ai = @as(TwoDigit, @intCast(a_mut[i]));
                s += A * ai;
                t -= C * ai;
                a_mut[i] = @intCast(@as(u128, @bitCast(s)) & DIGIT_MASK);
                s >>= DIGIT_BITS;
                t >>= DIGIT_BITS;
            }
        }

        std.debug.assert(s == 0);
        std.debug.assert(t == 0);

        while (size_a > 0 and a_mut[size_a - 1] == 0) size_a -= 1;
        while (size_b > 0 and b_mut[size_b - 1] == 0) size_b -= 1;
        std.debug.assert(size_a >= size_b);

        setUnsignedLength(a_bn, size_a);
        setUnsignedLength(b_bn, size_b);
    }

    a_bn = @ptrFromInt(layouts.UNTAG(a_cell));
    b_bn = @ptrFromInt(layouts.UNTAG(b_cell));
    setUnsignedLength(a_bn, size_a);
    setUnsignedLength(b_bn, size_b);

    var xx: i64 = if (size_a == 0) 0 else @intCast(a_bn.digits()[0]);
    var yy: i64 = if (size_b == 0) 0 else @intCast(b_bn.digits()[0]);
    while (yy != 0) {
        const tt = yy;
        yy = @mod(xx, yy);
        xx = tt;
    }

    return fromInt64(vm, xx);
}

// Bignum test bit — no allocation needed.
// For positive: direct digit lookup.
// For negative: compute two's complement digit on the fly.
pub fn testBit(x: *const Bignum, bit: Cell) bool {
    if (x.isZero()) return false;

    const digit_index = bit / DIGIT_BITS;
    const bit_index: u6 = @intCast(bit % DIGIT_BITS);

    if (!x.isNegative()) {
        // Positive: simple bit test
        if (digit_index >= x.length()) return false;
        return ((x.getDigit(digit_index) >> bit_index) & 1) != 0;
    }

    // Negative: test bit in two's complement representation.
    // Two's complement of -n is ~(n-1). We compute the digit at
    // digit_index by running a borrow chain from digit 0 up to
    // digit_index (subtract 1), then inverting.
    // C++ equivalent: !bignum_unsigned_logbitp(bit, bignum_bitwise_not(x))
    const len = x.length();
    var borrow: Cell = 1;
    for (0..digit_index + 1) |i| {
        const d = if (i < len) x.getDigit(i) else 0;
        if (d >= borrow) {
            if (i == digit_index) {
                // (d - borrow) inverted, test bit
                const tc_digit = (~(d - borrow)) & DIGIT_MASK;
                return ((tc_digit >> bit_index) & 1) != 0;
            }
            borrow = 0;
        } else {
            if (i == digit_index) {
                const tc_digit = (~((d +% RADIX -% borrow) & DIGIT_MASK)) & DIGIT_MASK;
                return ((tc_digit >> bit_index) & 1) != 0;
            }
            borrow = 1;
        }
    }
    // Beyond length: all ones in two's complement for negative
    return true;
}

// Helper functions for VM-based allocation
fn copyBignum(vm: *FactorVM, x: *const Bignum) !*Bignum {
    // Root x to protect from GC during allocation
    var x_cell: Cell = layouts.tagBignum(@constCast(x));
    vm.data_roots.append(vm.allocator, &x_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    const len = x.length();
    const is_neg = x.isNegative();
    const bn = try allocBignum(vm, len, is_neg);

    // Re-derive x after potential GC
    const rx: *const Bignum = @ptrFromInt(layouts.UNTAG(x_cell));
    @memcpy(bn.digits()[0..len], rx.digits()[0..len]);
    return bn;
}

fn copyBignumWithSign(vm: *FactorVM, x: *const Bignum, negative: bool) !*Bignum {
    const bn = try copyBignum(vm, x);
    bn.setNegative(negative);
    return bn;
}

fn negateBignum(vm: *FactorVM, x: *const Bignum) !*Bignum {
    if (x.isZero()) return copyBignum(vm, x);
    return copyBignumWithSign(vm, x, !x.isNegative());
}

fn allocBignumWithDigit(vm: *FactorVM, len: Cell, negative: bool, digit_val: Cell) !*Bignum {
    const bn = try allocBignum(vm, len, negative);
    if (len > 0) {
        bn.setDigit(0, digit_val);
    }
    return bn;
}

// Create bignum from double using VM nursery
pub fn fromDouble(vm: *FactorVM, x: f64) !*Bignum {
    // Handle special cases: infinity and NaN
    if (std.math.isInf(x) or std.math.isNan(x)) {
        return zeroBignum(vm);
    }

    // Use frexp to get significand and exponent
    const frexp_result = std.math.frexp(x);
    var significand = frexp_result.significand;
    const exponent = frexp_result.exponent;

    // If exponent <= 0, result is less than 1, return zero
    if (exponent <= 0) {
        return zeroBignum(vm);
    }

    // Special case: exponent == 1 means x = ±1
    if (exponent == 1) {
        const bn = try allocBignum(vm, 1, x < 0);
        bn.setDigit(0, 1);
        return bn;
    }

    // Determine sign and work with absolute significand
    const negative = x < 0;
    if (significand < 0) {
        significand = -significand;
    }

    // Calculate number of digits needed
    const length: Cell = @intCast(@divTrunc(exponent + DIGIT_BITS - 1, DIGIT_BITS));
    const result = try allocBignum(vm, length, negative);

    // Start from the high-order digit
    var scan: Cell = length;
    const digits_ptr = result.digits();

    // Handle odd bits at the top
    const odd_bits: u6 = @intCast(@mod(@as(i32, @intCast(exponent)), DIGIT_BITS));
    if (odd_bits > 0) {
        significand *= @as(f64, @floatFromInt(@as(Cell, 1) << odd_bits));
        const digit: Cell = @intFromFloat(significand);
        scan -= 1;
        digits_ptr[scan] = digit;
        significand -= @as(f64, @floatFromInt(digit));
    }

    // Process remaining digits
    while (scan > 0) {
        if (significand == 0) {
            while (scan > 0) {
                scan -= 1;
                digits_ptr[scan] = 0;
            }
            break;
        }

        significand *= @as(f64, @floatFromInt(RADIX));
        const digit: Cell = @intFromFloat(significand);
        scan -= 1;
        digits_ptr[scan] = digit;
        significand -= @as(f64, @floatFromInt(digit));
    }

    return result;
}

// Return absolute value of bignum
pub fn abs(vm: *FactorVM, x: *const Bignum) !*Bignum {
    if (!x.isNegative()) return @constCast(x);
    return copyBignumWithSign(vm, x, false);
}

// Return negated bignum
pub fn negate(vm: *FactorVM, x: *const Bignum) !*Bignum {
    if (x.isZero()) return @constCast(x);
    return copyBignumWithSign(vm, x, !x.isNegative());
}

// VM-based arithmetic helpers (allocate in nursery)
fn addUnsigned(vm: *FactorVM, x_in: *const Bignum, y_in: *const Bignum, negative: bool) !*Bignum {
    // Root both operands to protect from GC during allocation
    var x_cell: Cell = layouts.tagBignum(@constCast(x_in));
    var y_cell: Cell = layouts.tagBignum(@constCast(y_in));
    vm.data_roots.ensureUnusedCapacity(vm.allocator, 2) catch return error.OutOfMemory;
    vm.data_roots.appendAssumeCapacity(&x_cell);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&y_cell);
    defer _ = vm.data_roots.pop();

    // Ensure x is the longer one
    var x: *const Bignum = @ptrFromInt(layouts.UNTAG(x_cell));
    var y: *const Bignum = @ptrFromInt(layouts.UNTAG(y_cell));
    if (y.length() > x.length()) {
        const tmp = x_cell;
        x_cell = y_cell;
        y_cell = tmp;
        x = @ptrFromInt(layouts.UNTAG(x_cell));
        y = @ptrFromInt(layouts.UNTAG(y_cell));
    }

    const x_len = x.length();
    const y_len = y.length();
    const r = try allocBignum(vm, x_len, negative);

    // Re-derive pointers after potential GC
    x = @ptrFromInt(layouts.UNTAG(x_cell));
    y = @ptrFromInt(layouts.UNTAG(y_cell));
    const x_digits = x.digits()[0..x_len];
    const y_digits = y.digits()[0..y_len];
    const r_digits = r.digits()[0..x_len];

    var carry: Cell = 0;
    var i: Cell = 0;

    while (i < y_len) : (i += 1) {
        const sum = x_digits[i] + y_digits[i] + carry;
        r_digits[i] = sum & DIGIT_MASK;
        carry = sum >> DIGIT_BITS;
    }

    while (i < x_len) : (i += 1) {
        const sum = x_digits[i] + carry;
        r_digits[i] = sum & DIGIT_MASK;
        carry = sum >> DIGIT_BITS;
        if (carry == 0) {
            i += 1;
            break;
        }
    }

    @memcpy(r_digits[i..x_len], x_digits[i..x_len]);

    if (carry != 0) {
        // Root r before second allocation
        var r_cell: Cell = layouts.tagBignum(r);
        vm.data_roots.append(vm.allocator, &r_cell) catch return error.OutOfMemory;
        defer _ = vm.data_roots.pop();

        const r2 = try allocBignum(vm, x_len + 1, negative);
        // Re-derive r after potential GC
        const rooted_r: *const Bignum = @ptrFromInt(layouts.UNTAG(r_cell));
        @memcpy(r2.digits()[0..x_len], rooted_r.digits()[0..x_len]);
        r2.setDigit(x_len, carry);
        return r2;
    }

    return r;
}

fn subtractUnsigned(vm: *FactorVM, x_in: *const Bignum, y_in: *const Bignum, negative: bool) !*Bignum {
    // Root both operands to protect from GC during allocation
    var x_cell: Cell = layouts.tagBignum(@constCast(x_in));
    var y_cell: Cell = layouts.tagBignum(@constCast(y_in));
    vm.data_roots.ensureUnusedCapacity(vm.allocator, 2) catch return error.OutOfMemory;
    vm.data_roots.appendAssumeCapacity(&x_cell);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&y_cell);
    defer _ = vm.data_roots.pop();

    const x_len = x_in.length();
    const y_len = y_in.length();
    const r = try allocBignum(vm, x_len, negative);

    // Re-derive pointers after potential GC
    const x: *const Bignum = @ptrFromInt(layouts.UNTAG(x_cell));
    const y: *const Bignum = @ptrFromInt(layouts.UNTAG(y_cell));
    const x_digits = x.digits()[0..x_len];
    const y_digits = y.digits()[0..y_len];
    const r_digits = r.digits()[0..x_len];

    var borrow: Cell = 0;
    var i: Cell = 0;

    while (i < y_len) : (i += 1) {
        const x_digit = x_digits[i];
        const y_digit = y_digits[i] +% borrow;

        if (x_digit >= y_digit) {
            r_digits[i] = x_digit - y_digit;
            borrow = 0;
        } else {
            r_digits[i] = x_digit +% RADIX -% y_digit;
            borrow = 1;
        }
    }

    while (i < x_len) : (i += 1) {
        const x_digit = x_digits[i];
        if (x_digit >= borrow) {
            r_digits[i] = x_digit - borrow;
            borrow = 0;
            i += 1;
            break;
        } else {
            r_digits[i] = x_digit +% RADIX -% borrow;
        }
    }

    @memcpy(r_digits[i..x_len], x_digits[i..x_len]);

    return trim(vm, r);
}

// Fast path: multiply bignum by a single digit (O(n) instead of O(n²))
fn multiplyBySingleDigitVM(vm: *FactorVM, x_in: *const Bignum, digit: Cell, negative: bool) !*Bignum {
    std.debug.assert(digit != 0);

    // Root operand to protect from GC during allocation
    var x_cell: Cell = layouts.tagBignum(@constCast(x_in));
    vm.data_roots.append(vm.allocator, &x_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    const x_len = x_in.length();
    const r = try allocBignum(vm, x_len + 1, negative);

    // Re-derive pointer after potential GC
    const x: *const Bignum = @ptrFromInt(layouts.UNTAG(x_cell));
    const x_digits = x.digits()[0..x_len];
    const r_digits = r.digits()[0 .. x_len + 1];

    const multiplier: u128 = digit;
    var carry: u128 = 0;

    for (0..x_len) |i| {
        const product = @as(u128, x_digits[i]) * multiplier + carry;
        r_digits[i] = @truncate(product & DIGIT_MASK);
        carry = product >> DIGIT_BITS;
    }

    r_digits[x_len] = @truncate(carry);
    return trim(vm, r);
}

// Karatsuba threshold: below this digit count, use schoolbook O(n²).
// Typical optimal range is 32-96 depending on platform overhead.
const KARATSUBA_THRESHOLD: usize = 32;

// Schoolbook multiplication on raw digit arrays. Result must be zeroed, len = x_len + y_len.
fn schoolbookMulDigits(x: []const Cell, y: []const Cell, r: []Cell) void {
    std.debug.assert(r.len >= x.len + y.len);
    for (0..x.len) |i| {
        const xd: u128 = x[i];
        var carry: u128 = 0;
        for (0..y.len) |j| {
            const product = xd * @as(u128, y[j]) + @as(u128, r[i + j]) + carry;
            r[i + j] = @truncate(product & DIGIT_MASK);
            carry = product >> DIGIT_BITS;
        }
        var k: usize = i + y.len;
        while (carry != 0 and k < r.len) : (k += 1) {
            const sum = @as(u128, r[k]) + carry;
            r[k] = @truncate(sum & DIGIT_MASK);
            carry = sum >> DIGIT_BITS;
        }
    }
}

// Schoolbook squaring on raw digit arrays. Result must be zeroed, len = 2 * x_len.
fn schoolbookSquareDigits(x: []const Cell, r: []Cell) void {
    std.debug.assert(r.len >= 2 * x.len);
    for (0..x.len) |i| {
        var carry: u128 = 0;
        const f_base: u128 = x[i];

        // Square the current digit
        carry = @as(u128, r[i * 2]) + f_base * f_base;
        r[i * 2] = @truncate(carry & DIGIT_MASK);
        carry >>= DIGIT_BITS;

        // Double f for cross-products
        const f = f_base << 1;
        for (i + 1..x.len) |j| {
            carry += @as(u128, r[i + j]) + @as(u128, x[j]) * f;
            r[i + j] = @truncate(carry & DIGIT_MASK);
            carry >>= DIGIT_BITS;
        }

        // Propagate carry
        var k: usize = i + x.len;
        while (carry != 0 and k < r.len) : (k += 1) {
            carry += @as(u128, r[k]);
            r[k] = @truncate(carry & DIGIT_MASK);
            carry >>= DIGIT_BITS;
        }
    }
}

// Add digit arrays: r = a + b, return carry (0 or 1).
// a.len >= b.len. r.len >= a.len. Excess r digits are propagated into.
fn addDigits(a: []const Cell, b: []const Cell, r: []Cell) Cell {
    std.debug.assert(a.len >= b.len);
    std.debug.assert(r.len >= a.len);
    var carry: u128 = 0;
    for (0..b.len) |i| {
        carry += @as(u128, a[i]) + @as(u128, b[i]);
        r[i] = @truncate(carry & DIGIT_MASK);
        carry >>= DIGIT_BITS;
    }
    for (b.len..a.len) |i| {
        carry += @as(u128, a[i]);
        r[i] = @truncate(carry & DIGIT_MASK);
        carry >>= DIGIT_BITS;
    }
    return @truncate(carry);
}

// Subtract digit arrays: r = a - b (unsigned, a >= b assumed). Return borrow for debug.
fn subtractDigits(a: []const Cell, b: []const Cell, r: []Cell) void {
    std.debug.assert(a.len >= b.len);
    std.debug.assert(r.len >= a.len);
    var borrow: i128 = 0;
    for (0..b.len) |i| {
        borrow += @as(i128, a[i]) - @as(i128, b[i]);
        if (borrow >= 0) {
            r[i] = @intCast(@as(u128, @bitCast(borrow)) & DIGIT_MASK);
            borrow >>= DIGIT_BITS;
        } else {
            r[i] = @intCast(@as(u128, @bitCast(borrow + @as(i128, RADIX))) & DIGIT_MASK);
            borrow = -1;
        }
    }
    for (b.len..a.len) |i| {
        borrow += @as(i128, a[i]);
        if (borrow >= 0) {
            r[i] = @intCast(@as(u128, @bitCast(borrow)) & DIGIT_MASK);
            borrow >>= DIGIT_BITS;
        } else {
            r[i] = @intCast(@as(u128, @bitCast(borrow + @as(i128, RADIX))) & DIGIT_MASK);
            borrow = -1;
        }
    }
    std.debug.assert(borrow == 0);
}

// Add into: r += a, shifted by offset digits. r.len must be large enough.
fn addInto(r: []Cell, a: []const Cell, offset: usize) void {
    var carry: u128 = 0;
    for (0..a.len) |i| {
        carry += @as(u128, r[offset + i]) + @as(u128, a[i]);
        r[offset + i] = @truncate(carry & DIGIT_MASK);
        carry >>= DIGIT_BITS;
    }
    var k: usize = offset + a.len;
    while (carry != 0 and k < r.len) : (k += 1) {
        carry += @as(u128, r[k]);
        r[k] = @truncate(carry & DIGIT_MASK);
        carry >>= DIGIT_BITS;
    }
}

// Subtract from: r -= a, shifted by offset digits.
fn subtractFrom(r: []Cell, a: []const Cell, offset: usize) void {
    var borrow: i128 = 0;
    for (0..a.len) |i| {
        borrow += @as(i128, r[offset + i]) - @as(i128, a[i]);
        if (borrow >= 0) {
            r[offset + i] = @intCast(@as(u128, @bitCast(borrow)) & DIGIT_MASK);
            borrow >>= DIGIT_BITS;
        } else {
            r[offset + i] = @intCast(@as(u128, @bitCast(borrow + @as(i128, RADIX))) & DIGIT_MASK);
            borrow = -1;
        }
    }
    var k: usize = offset + a.len;
    while (borrow != 0 and k < r.len) : (k += 1) {
        borrow += @as(i128, r[k]);
        if (borrow >= 0) {
            r[k] = @intCast(@as(u128, @bitCast(borrow)) & DIGIT_MASK);
            borrow >>= DIGIT_BITS;
        } else {
            r[k] = @intCast(@as(u128, @bitCast(borrow + @as(i128, RADIX))) & DIGIT_MASK);
            borrow = -1;
        }
    }
}

// Effective length of a digit slice (strip trailing zeros).
fn effectiveLen(digits: []const Cell) usize {
    var n = digits.len;
    while (n > 0 and digits[n - 1] == 0) n -= 1;
    return n;
}

// Multiply digit arrays: dispatches to schoolbook or Karatsuba based on size.
// r must be zeroed, r.len >= x.len + y.len.
fn mulDigits(x_in: []const Cell, y_in: []const Cell, r: []Cell, scratch: []Cell) void {
    const x = x_in[0..effectiveLen(x_in)];
    const y = y_in[0..effectiveLen(y_in)];
    if (x.len == 0 or y.len == 0) return;
    if (@max(x.len, y.len) < KARATSUBA_THRESHOLD) {
        schoolbookMulDigits(x, y, r);
    } else {
        karatsubaMulDigits(x, y, r, scratch);
    }
}

// Square digit arrays: dispatches to schoolbook or Karatsuba based on size.
// r must be zeroed, r.len >= 2 * x.len.
fn squareDigits(x_in: []const Cell, r: []Cell, scratch: []Cell) void {
    const x = x_in[0..effectiveLen(x_in)];
    if (x.len == 0) return;
    if (x.len < KARATSUBA_THRESHOLD) {
        schoolbookSquareDigits(x, r);
    } else {
        karatsubaSquareDigits(x, r, scratch);
    }
}

// Karatsuba multiplication on raw digit arrays.
// r must be zeroed, r.len >= x.len + y.len.
// scratch must have at least karatsubaScratchSize(max(x.len, y.len)) elements.
fn karatsubaMulDigits(x: []const Cell, y: []const Cell, r: []Cell, scratch: []Cell) void {
    std.debug.assert(x.len >= KARATSUBA_THRESHOLD or y.len >= KARATSUBA_THRESHOLD);
    std.debug.assert(x.len > 0 and y.len > 0);

    // Split at half the larger operand
    const k = @max(x.len, y.len) / 2;

    // x = x1*B^k + x0, y = y1*B^k + y0
    const x0 = x[0..@min(k, x.len)];
    const x1 = if (k < x.len) x[k..] else x[0..0];
    const y0 = y[0..@min(k, y.len)];
    const y1 = if (k < y.len) y[k..] else y[0..0];

    // Scratch layout: [x0+x1 | y0+y1 | z1_product | deeper recursion...]
    const sum_x_len = @max(x0.len, x1.len) + 1; // +1 for carry
    const sum_y_len = @max(y0.len, y1.len) + 1;
    const z1_len = sum_x_len + sum_y_len;

    const sum_x = scratch[0..sum_x_len];
    const sum_y = scratch[sum_x_len .. sum_x_len + sum_y_len];
    const z1_buf = scratch[sum_x_len + sum_y_len .. sum_x_len + sum_y_len + z1_len];
    const deeper = scratch[sum_x_len + sum_y_len + z1_len ..];

    // z0 = x0 * y0 (stored directly in r[0..2k])
    const z0_len = x0.len + y0.len;
    mulDigits(x0, y0, r[0..z0_len], deeper);

    // z2 = x1 * y1 (stored directly in r[2k..])
    if (x1.len > 0 and y1.len > 0) {
        const z2_start = 2 * k;
        const z2_len = x1.len + y1.len;
        mulDigits(x1, y1, r[z2_start .. z2_start + z2_len], deeper);
    }

    // Compute x0+x1 and y0+y1
    @memset(sum_x, 0);
    @memset(sum_y, 0);
    if (x0.len >= x1.len) {
        sum_x[x0.len] = addDigits(x0, x1, sum_x[0..x0.len]);
    } else {
        sum_x[x1.len] = addDigits(x1, x0, sum_x[0..x1.len]);
    }
    if (y0.len >= y1.len) {
        sum_y[y0.len] = addDigits(y0, y1, sum_y[0..y0.len]);
    } else {
        sum_y[y1.len] = addDigits(y1, y0, sum_y[0..y1.len]);
    }

    // z1_buf = (x0+x1) * (y0+y1)
    const sx = sum_x[0..effectiveLen(sum_x)];
    const sy = sum_y[0..effectiveLen(sum_y)];
    @memset(z1_buf, 0);
    mulDigits(sx, sy, z1_buf, deeper);

    // z1 = z1_buf - z0 - z2, then add z1 << k into result
    // z1_buf -= z0 (which is in r[0..z0_len])
    subtractFrom(z1_buf, r[0..z0_len], 0);
    // z1_buf -= z2 (which is in r[2k..])
    if (x1.len > 0 and y1.len > 0) {
        const z2_start = 2 * k;
        const z2_len = x1.len + y1.len;
        subtractFrom(z1_buf, r[z2_start .. z2_start + z2_len], 0);
    }

    // r += z1 << k
    addInto(r, z1_buf[0..effectiveLen(z1_buf)], k);
}

// Karatsuba squaring on raw digit arrays (2 recursive calls instead of 3).
// r must be zeroed, r.len >= 2 * x.len.
fn karatsubaSquareDigits(x: []const Cell, r: []Cell, scratch: []Cell) void {
    std.debug.assert(x.len >= KARATSUBA_THRESHOLD);

    const k = x.len / 2;

    // x = x1*B^k + x0
    const x0 = x[0..k];
    const x1 = x[k..];

    // Scratch layout: [z1_product (2*(k+1)) | deeper...]
    const z1_len = (x0.len + x1.len) + (x0.len + x1.len);
    const z1_buf = scratch[0..z1_len];
    const deeper = scratch[z1_len..];

    // z0 = x0² (in r[0..2k])
    squareDigits(x0, r[0 .. 2 * k], deeper);

    // z2 = x1² (in r[2k..])
    if (x1.len > 0) {
        squareDigits(x1, r[2 * k .. 2 * k + 2 * x1.len], deeper);
    }

    // z1 = 2 * x0 * x1, add shifted by k
    // Compute x0 * x1 into z1_buf, then double and add
    const cross_len = x0.len + x1.len;
    @memset(z1_buf[0..cross_len], 0);
    mulDigits(x0, x1, z1_buf[0..cross_len], deeper);

    // Double z1 (shift left by 1 bit within digits)
    const cross = z1_buf[0..cross_len];
    var carry: Cell = 0;
    for (0..cross_len) |i| {
        const doubled: u128 = @as(u128, cross[i]) * 2 + carry;
        cross[i] = @truncate(doubled & DIGIT_MASK);
        carry = @truncate(doubled >> DIGIT_BITS);
    }

    // r += 2*x0*x1 << k
    addInto(r, cross[0..effectiveLen(cross)], k);
    if (carry != 0) {
        // Propagate the carry from doubling
        var pos = k + cross_len;
        var c: u128 = carry;
        while (c != 0 and pos < r.len) : (pos += 1) {
            c += @as(u128, r[pos]);
            r[pos] = @truncate(c & DIGIT_MASK);
            c >>= DIGIT_BITS;
        }
    }
}

// Compute scratch space needed for Karatsuba. O(n) total across recursion.
fn karatsubaScratchSize(n: usize) usize {
    if (n < KARATSUBA_THRESHOLD) return 0;
    // Per level: sum_x(k/2+2) + sum_y(k/2+2) + z1(2*(k/2+2)) = ~4*(k/2+2)
    // Geometric series sums to ~8n. Use 10n for safety margin.
    return 10 * n;
}

fn multiplyUnsigned(vm: *FactorVM, x_in: *const Bignum, y_in: *const Bignum, negative: bool) !*Bignum {
    // Root both operands to protect from GC during allocation
    var x_cell: Cell = layouts.tagBignum(@constCast(x_in));
    var y_cell: Cell = layouts.tagBignum(@constCast(y_in));
    vm.data_roots.ensureUnusedCapacity(vm.allocator, 2) catch return error.OutOfMemory;
    vm.data_roots.appendAssumeCapacity(&x_cell);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&y_cell);
    defer _ = vm.data_roots.pop();

    const x_len = x_in.length();
    const y_len = y_in.length();
    const r_len = x_len + y_len;
    const r = try allocBignumZeroed(vm, r_len, negative);

    // Re-derive pointers after potential GC
    const x: *const Bignum = @ptrFromInt(layouts.UNTAG(x_cell));
    const y: *const Bignum = @ptrFromInt(layouts.UNTAG(y_cell));
    const x_digits = x.digits()[0..x_len];
    const y_digits = y.digits()[0..y_len];
    const r_digits = r.digits()[0..r_len];

    const scratch_size = karatsubaScratchSize(@max(x_len, y_len));
    var empty = [_]Cell{};
    const scratch = if (scratch_size > 0)
        vm.allocator.alloc(Cell, scratch_size) catch return error.OutOfMemory
    else
        empty[0..];
    defer if (scratch_size > 0) vm.allocator.free(scratch);
    if (scratch_size > 0) @memset(scratch, 0);
    mulDigits(x_digits, y_digits, r_digits, scratch);

    return trim(vm, r);
}

fn divideUnsigned(vm: *FactorVM, numerator: *const Bignum, denominator: *const Bignum, q_negative: bool, r_negative: bool) !DivisionResult {
    if (denominator.length() == 1) {
        return divideBySingleDigit(vm, numerator, denominator.getDigit(0), q_negative, r_negative);
    }
    // Multi-digit division using Knuth's Algorithm D
    return divideKnuth(vm, numerator, denominator, q_negative, r_negative);
}

fn divideBySingleDigit(vm: *FactorVM, numerator_in: *const Bignum, divisor: Cell, q_negative: bool, r_negative: bool) !DivisionResult {
    // Root numerator to protect from GC during allocation
    var num_cell: Cell = layouts.tagBignum(@constCast(numerator_in));
    vm.data_roots.append(vm.allocator, &num_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    const n_len = numerator_in.length();
    const q = try allocBignum(vm, n_len, q_negative);

    // Re-derive numerator after potential GC
    const numerator: *const Bignum = @ptrFromInt(layouts.UNTAG(num_cell));

    // Perform the division. For small divisors (< RADIX_ROOT = 2^31), use the
    // half-digit approach from C++ bignum_destructive_scale_down. This stays
    // within 64-bit arithmetic (critical for Rosetta 2 performance where
    // 128÷64 divq translates to a slow runtime call).
    const rem = if (divisor < RADIX_ROOT)
        scaleDownHalfDigit(numerator, q, n_len, divisor)
    else
        scaleDownFull(numerator, q, n_len, divisor);

    // Root q before trim (which allocates)
    var q_cell: Cell = layouts.tagBignum(q);
    vm.data_roots.append(vm.allocator, &q_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    const trimmed_q = try trim(vm, q);

    // Update q_cell to trimmed result, root it for remainder allocation
    q_cell = layouts.tagBignum(trimmed_q);

    const r = try allocBignumWithDigit(vm, 1, r_negative, rem);
    const trimmed_r = try trim(vm, r);

    // Re-derive trimmed_q from rooted cell
    const final_q: *Bignum = @ptrFromInt(layouts.UNTAG(q_cell));
    return .{ .quotient = final_q, .remainder = trimmed_r };
}

// Quotient-only single-digit division. Skips remainder allocation.
fn divideBySingleDigitQuotientOnly(vm: *FactorVM, numerator_in: *const Bignum, divisor: Cell, q_negative: bool) !*Bignum {
    var num_cell: Cell = layouts.tagBignum(@constCast(numerator_in));
    vm.data_roots.append(vm.allocator, &num_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    const n_len = numerator_in.length();
    const q = try allocBignum(vm, n_len, q_negative);
    const numerator: *const Bignum = @ptrFromInt(layouts.UNTAG(num_cell));

    _ = if (divisor < RADIX_ROOT)
        scaleDownHalfDigit(numerator, q, n_len, divisor)
    else
        scaleDownFull(numerator, q, n_len, divisor);

    return trim(vm, q);
}

// Remainder-only single-digit division. Skips quotient allocation.
fn divideBySingleDigitRemainderOnly(vm: *FactorVM, numerator_in: *const Bignum, divisor: Cell, r_negative: bool) !*Bignum {
    var num_cell: Cell = layouts.tagBignum(@constCast(numerator_in));
    vm.data_roots.append(vm.allocator, &num_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    const n_len = numerator_in.length();
    const numerator: *const Bignum = @ptrFromInt(layouts.UNTAG(num_cell));

    const rem = if (divisor < RADIX_ROOT) blk: {
        var rem_acc: Cell = 0;
        var i: Cell = n_len;
        while (i > 0) {
            i -= 1;
            const two_digits = numerator.getDigit(i);
            const num_high = (rem_acc << HALF_DIGIT_BITS) | (two_digits >> HALF_DIGIT_BITS);
            const num_low = ((num_high % divisor) << HALF_DIGIT_BITS) | (two_digits & HALF_DIGIT_MASK);
            rem_acc = num_low % divisor;
        }
        break :blk rem_acc;
    } else blk: {
        var rem_acc: Cell = 0;
        var i: Cell = n_len;
        while (i > 0) {
            i -= 1;
            const digit = numerator.getDigit(i);
            const lo: u64 = (rem_acc << DIGIT_BITS) | digit;
            const hi: u64 = rem_acc >> @intCast(@as(u7, 64) - DIGIT_BITS);
            const result = divmod128by64(hi, lo, divisor);
            rem_acc = result.r;
        }
        break :blk rem_acc;
    };

    if (rem == 0) return zeroBignum(vm);
    return allocBignumWithDigit(vm, 1, r_negative, rem);
}

// Half-digit division for small denominators (< RADIX_ROOT).
// Matches C++ bignum_destructive_scale_down. Each digit is split into
// two half-digits and divided separately using pure 64-bit arithmetic.
// This avoids 128-bit division which is slow under Rosetta 2.
fn scaleDownHalfDigit(numerator: *const Bignum, q: *Bignum, n_len: Cell, divisor: Cell) Cell {
    std.debug.assert(divisor > 0 and divisor < RADIX_ROOT);
    var rem_acc: Cell = 0;
    var i: Cell = n_len;
    while (i > 0) {
        i -= 1;
        const two_digits = numerator.getDigit(i);
        // High half: (remainder << HALF_DIGIT_BITS) | high_half_of_digit
        const num_high = (rem_acc << HALF_DIGIT_BITS) | (two_digits >> HALF_DIGIT_BITS);
        const q_high = num_high / divisor;
        // Low half: (remainder_of_high << HALF_DIGIT_BITS) | low_half_of_digit
        const num_low = ((num_high % divisor) << HALF_DIGIT_BITS) | (two_digits & HALF_DIGIT_MASK);
        const q_low = num_low / divisor;
        rem_acc = num_low % divisor;
        q.setDigit(i, (q_high << HALF_DIGIT_BITS) | q_low);
    }
    return rem_acc;
}

// Full-precision division for large single-digit denominators (>= RADIX_ROOT).
// Uses 128-bit arithmetic via native divq or software fallback.
fn scaleDownFull(numerator: *const Bignum, q: *Bignum, n_len: Cell, divisor: Cell) Cell {
    var rem: Cell = 0;
    var i: Cell = n_len;
    while (i > 0) {
        i -= 1;
        const digit = numerator.getDigit(i);
        const lo: u64 = (rem << DIGIT_BITS) | digit;
        const hi: u64 = rem >> @intCast(@as(u7, 64) - DIGIT_BITS);
        const result = divmod128by64(hi, lo, divisor);
        q.setDigit(i, result.q);
        rem = result.r;
    }
    return rem;
}

// Knuth's Algorithm D for multi-digit division
// Reference: The Art of Computer Programming, Vol. 2, Section 4.3.1
fn divideKnuth(vm: *FactorVM, numerator_in: *const Bignum, denominator_in: *const Bignum, q_negative: bool, r_negative: bool) !DivisionResult {
    const result = try divideKnuthCore(vm, numerator_in, denominator_in, q_negative, r_negative, true, true);
    return .{ .quotient = result.quotient.?, .remainder = result.remainder.? };
}

fn divideKnuthQuotientOnly(vm: *FactorVM, numerator_in: *const Bignum, denominator_in: *const Bignum, q_negative: bool) !*Bignum {
    const result = try divideKnuthCore(vm, numerator_in, denominator_in, q_negative, false, true, false);
    return result.quotient.?;
}

fn divideKnuthRemainderOnly(vm: *FactorVM, numerator_in: *const Bignum, denominator_in: *const Bignum, r_negative: bool) !*Bignum {
    const result = try divideKnuthCore(vm, numerator_in, denominator_in, false, r_negative, false, true);
    return result.remainder.?;
}

const KnuthCoreResult = struct {
    quotient: ?*Bignum = null,
    remainder: ?*Bignum = null,
};

fn divideKnuthCore(
    vm: *FactorVM,
    numerator_in: *const Bignum,
    denominator_in: *const Bignum,
    q_negative: bool,
    r_negative: bool,
    comptime want_q: bool,
    comptime want_r: bool,
) !KnuthCoreResult {
    // Root both inputs to protect from GC
    var num_cell: Cell = layouts.tagBignum(@constCast(numerator_in));
    var den_cell: Cell = layouts.tagBignum(@constCast(denominator_in));
    vm.data_roots.ensureUnusedCapacity(vm.allocator, 2) catch return error.OutOfMemory;
    vm.data_roots.appendAssumeCapacity(&num_cell);
    defer _ = vm.data_roots.pop();
    vm.data_roots.appendAssumeCapacity(&den_cell);
    defer _ = vm.data_roots.pop();

    const n_len = numerator_in.length();
    const d_len = denominator_in.length();
    const q_len = n_len - d_len + 1;

    // Step D1: Normalize - find shift to make top digit of denominator >= RADIX/2
    const top_d = denominator_in.getDigit(d_len - 1);
    const bitlen: u6 = @intCast(@bitSizeOf(Cell) - @clz(top_d));
    const norm_shift: u6 = @intCast(DIGIT_BITS - bitlen);

    // Shift numerator and denominator for normalization (may GC)
    var u_cell: Cell = undefined;
    if (norm_shift > 0) {
        const u_ptr = try shiftLeft(vm, @as(*const Bignum, @ptrFromInt(layouts.UNTAG(num_cell))), norm_shift);
        u_cell = layouts.tagBignum(u_ptr);
    } else {
        u_cell = num_cell;
    }
    vm.data_roots.append(vm.allocator, &u_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    var vv_cell: Cell = undefined;
    if (norm_shift > 0) {
        const vv_ptr = try shiftLeft(vm, @as(*const Bignum, @ptrFromInt(layouts.UNTAG(den_cell))), norm_shift);
        vv_cell = layouts.tagBignum(vv_ptr);
    } else {
        vv_cell = den_cell;
    }
    vm.data_roots.append(vm.allocator, &vv_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    var q_cell: Cell = 0;
    if (comptime want_q) {
        const q = try allocBignumZeroed(vm, q_len, q_negative);
        q_cell = layouts.tagBignum(q);
        vm.data_roots.append(vm.allocator, &q_cell) catch return error.OutOfMemory;
        defer _ = vm.data_roots.pop();
    }

    // Create working copy of numerator with extra digit (may GC)
    const u_for_len: *const Bignum = @ptrFromInt(layouts.UNTAG(u_cell));
    const work_len = u_for_len.length() + 1;
    const work = try allocBignumZeroed(vm, work_len, false);
    var work_cell: Cell = layouts.tagBignum(work);
    vm.data_roots.append(vm.allocator, &work_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    // Re-derive u after work allocation, copy digits
    const u_final: *const Bignum = @ptrFromInt(layouts.UNTAG(u_cell));
    for (0..u_final.length()) |i| {
        work.setDigit(i, u_final.getDigit(i));
    }

    // Re-derive vv for the main loop
    var vv: *const Bignum = @ptrFromInt(layouts.UNTAG(vv_cell));

    // Get top two digits of divisor for quotient estimation
    const v1 = vv.getDigit(d_len - 1);
    const v2 = if (d_len > 1) vv.getDigit(d_len - 2) else 0;

    var q_ptr: *Bignum = undefined;
    if (comptime want_q) {
        q_ptr = @ptrFromInt(layouts.UNTAG(q_cell));
    }
    var work_ptr: *Bignum = @ptrFromInt(layouts.UNTAG(work_cell));

    // Step D2-D7: Main division loop (no allocations)
    var j: Cell = q_len;
    while (j > 0) {
        j -= 1;

        // Step D3: Calculate estimate quotient digit (qhat)
        const uj = work_ptr.getDigit(j + d_len);
        const uj1 = work_ptr.getDigit(j + d_len - 1);

        var qhat: Cell = undefined;
        var rhat: u128 = undefined;

        if (uj >= v1) {
            qhat = RADIX - 1;
            rhat = @as(u128, uj1) + @as(u128, v1);
        } else {
            const two_digits: u128 = (@as(u128, uj) << DIGIT_BITS) | uj1;
            qhat = @intCast(two_digits / v1);
            rhat = two_digits % v1;
        }

        // Step D3 (continued): Refine estimate
        while (true) {
            // Check if qhat is too large
            const uj2 = if (j + d_len >= 2) work_ptr.getDigit(j + d_len - 2) else 0;

            // Check: qhat * v2 > (rhat << DIGIT_BITS) + uj2
            if (rhat < (@as(u128, 1) << DIGIT_BITS)) {
                const prod: u128 = @as(u128, qhat) * v2;
                const comparand: u128 = (rhat << DIGIT_BITS) + uj2;
                if (prod > comparand) {
                    qhat -= 1;
                    rhat += v1;
                    continue;
                }
            }
            break;
        }

        // Step D4: Multiply and subtract
        var borrow: SignedDigit = 0;
        var k: Cell = 0;
        while (k < d_len) : (k += 1) {
            const prod: u128 = @as(u128, qhat) * vv.getDigit(k);
            const prod_low: SignedDigit = @as(SignedDigit, @truncate(@as(i128, @bitCast(prod)) & @as(i128, @bitCast(@as(u128, DIGIT_MASK)))));
            const work_digit: SignedDigit = @bitCast(work_ptr.getDigit(j + k));
            const sub: SignedDigit = work_digit -% prod_low -% borrow;

            work_ptr.setDigit(j + k, @bitCast(sub & @as(SignedDigit, @bitCast(DIGIT_MASK))));
            borrow = @as(SignedDigit, @truncate(@as(i128, @bitCast(prod)) >> DIGIT_BITS)) -% (sub >> DIGIT_BITS);
        }

        // Update top digit with final borrow
        const final_work: SignedDigit = @bitCast(work_ptr.getDigit(j + d_len));
        const final_sub: SignedDigit = final_work -% borrow;
        work_ptr.setDigit(j + d_len, @bitCast(final_sub));

        // Step D5: Test remainder - set quotient digit
        if (comptime want_q) {
            q_ptr.setDigit(j, qhat);
        }

        // Step D6: Add back if we subtracted too much (qhat was too large)
        if (final_sub < 0) {
            if (comptime want_q) {
                q_ptr.setDigit(j, qhat - 1);
            }

            // Add divisor back to restore correct remainder
            var carry: Cell = 0;
            k = 0;
            while (k < d_len) : (k += 1) {
                const sum = work_ptr.getDigit(j + k) +% vv.getDigit(k) +% carry;
                work_ptr.setDigit(j + k, sum & DIGIT_MASK);
                carry = sum >> DIGIT_BITS;
            }
            work_ptr.setDigit(j + d_len, work_ptr.getDigit(j + d_len) +% carry);
        }
    }

    var out = KnuthCoreResult{};

    if (comptime want_q) {
        // Step D8: finalize quotient
        q_ptr = @ptrFromInt(layouts.UNTAG(q_cell));
        const trimmed_q = try trim(vm, q_ptr);
        q_cell = layouts.tagBignum(trimmed_q);
        out.quotient = @ptrFromInt(layouts.UNTAG(q_cell));
    }

    if (comptime want_r) {
        // Step D8: Unnormalize remainder
        var rem = try allocBignum(vm, d_len, r_negative);

        // Re-derive work after rem allocation
        work_ptr = @ptrFromInt(layouts.UNTAG(work_cell));
        for (0..d_len) |i| {
            rem.setDigit(i, work_ptr.getDigit(i));
        }

        // Shift remainder right to unnormalize
        if (norm_shift > 0) {
            rem = try shiftRightInPlace(rem, norm_shift);
        }
        const trimmed_r = try trim(vm, rem);
        out.remainder = trimmed_r;
    }

    return out;
}

// Shift right in place (for unnormalization)
fn shiftRightInPlace(x: *Bignum, shift_bits: Cell) !*Bignum {
    if (shift_bits == 0) return x;

    const bit_shift: u6 = @intCast(shift_bits % DIGIT_BITS);
    if (bit_shift == 0) return x;

    const x_len = x.length();
    const d = x.digits();
    for (0..x_len) |i| {
        var digit = d[i] >> bit_shift;
        if (i + 1 < x_len) {
            digit |= (d[i + 1] << (@as(u6, DIGIT_BITS) - bit_shift)) & DIGIT_MASK;
        }
        d[i] = digit;
    }

    return x;
}

inline fn shiftLeft(vm: *FactorVM, x_in: *const Bignum, shift_bits: Cell) !*Bignum {
    // Root x to protect from GC during allocation
    var x_cell: Cell = layouts.tagBignum(@constCast(x_in));
    vm.data_roots.append(vm.allocator, &x_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    const digit_shift = shift_bits / DIGIT_BITS;
    const bit_shift: u6 = @intCast(shift_bits % DIGIT_BITS);

    const x_len = x_in.length();
    const is_neg = x_in.isNegative();
    const r = try allocBignumZeroed(vm, x_len + digit_shift + 1, is_neg);

    // Re-derive x after potential GC, pre-compute digit slices
    const x: *const Bignum = @ptrFromInt(layouts.UNTAG(x_cell));
    const x_digits = x.digits()[0..x_len];
    const r_digits = r.digits();

    if (bit_shift == 0) {
        @memcpy(r_digits[digit_shift..][0..x_len], x_digits);
    } else {
        var carry: Cell = 0;
        for (0..x_len) |i| {
            const digit = x_digits[i];
            r_digits[i + digit_shift] = ((digit << bit_shift) | carry) & DIGIT_MASK;
            carry = digit >> (@as(u6, DIGIT_BITS) - bit_shift);
        }
        if (carry != 0) {
            r_digits[x_len + digit_shift] = carry;
        }
    }

    return trim(vm, r);
}

inline fn shiftRight(vm: *FactorVM, x_in: *const Bignum, shift_bits: Cell) !*Bignum {
    const digit_shift = shift_bits / DIGIT_BITS;
    const bit_shift: u6 = @intCast(shift_bits % DIGIT_BITS);

    const x_len = x_in.length();
    if (digit_shift >= x_len) {
        return zeroBignum(vm);
    }

    // Root x to protect from GC during allocation
    var x_cell: Cell = layouts.tagBignum(@constCast(x_in));
    vm.data_roots.append(vm.allocator, &x_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    const r_len = x_len - digit_shift;
    const is_neg = x_in.isNegative();
    const r = try allocBignum(vm, r_len, is_neg);

    // Re-derive x after potential GC, pre-compute digit slices
    const x: *const Bignum = @ptrFromInt(layouts.UNTAG(x_cell));
    const x_digits = x.digits();
    const r_digits = r.digits();

    if (bit_shift == 0) {
        @memcpy(r_digits[0..r_len], x_digits[digit_shift..][0..r_len]);
    } else {
        for (0..r_len) |i| {
            var digit = x_digits[i + digit_shift] >> bit_shift;
            if (i + digit_shift + 1 < x_len) {
                digit |= (x_digits[i + digit_shift + 1] << (@as(u6, DIGIT_BITS) - bit_shift)) & DIGIT_MASK;
            }
            r_digits[i] = digit;
        }
    }

    return trim(vm, r);
}

inline fn trim(vm: *FactorVM, bn: *Bignum) !*Bignum {
    const orig_len = bn.length();
    const d = bn.digits();
    var new_len = orig_len;
    while (new_len > 0 and d[new_len - 1] == 0) {
        new_len -= 1;
    }

    if (new_len == orig_len) return bn;

    const negative = if (new_len == 0) false else bn.isNegative();

    // In-place trim when bignum is in the nursery.
    // Matches C++ reallot_array_in_place_p: nursery is a bump allocator,
    // so shrinking just wastes trailing bytes (reclaimed on next GC flush).
    const bn_addr = @intFromPtr(bn);
    const nursery = &vm.vm_asm.nursery;
    if (bn_addr >= nursery.start and bn_addr < nursery.here) {
        bn.capacity = layouts.tagFixnum(@as(Fixnum, @intCast(new_len + 1)));
        bn.setNegative(negative);
        return bn;
    }

    // Fall back to allocate + copy for non-nursery bignums (aging/tenured)
    var bn_cell: Cell = layouts.tagBignum(bn);
    vm.data_roots.append(vm.allocator, &bn_cell) catch return error.OutOfMemory;
    defer _ = vm.data_roots.pop();

    const new_bn = try allocBignum(vm, new_len, negative);
    const rooted_bn: *const Bignum = @ptrFromInt(layouts.UNTAG(bn_cell));
    for (0..new_len) |i| {
        new_bn.setDigit(i, rooted_bn.getDigit(i));
    }
    return new_bn;
}
