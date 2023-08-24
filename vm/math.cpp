#include "master.hpp"
#include <sstream>
#include <iomanip>
#include <stdexcept>

namespace factor {

void factor_vm::primitive_bignum_to_fixnum() {
  ctx->replace(tag_fixnum(bignum_to_fixnum(untag<bignum>(ctx->peek()))));
}

void factor_vm::primitive_bignum_to_fixnum_strict() {
  ctx->replace(tag_fixnum(bignum_to_fixnum_strict(untag<bignum>(ctx->peek()))));
}

void factor_vm::primitive_float_to_fixnum() {
  ctx->replace(tag_fixnum(float_to_fixnum(ctx->peek())));
}

// does not allocate, even though from_signed_cell can allocate
// Division can only overflow when we are dividing the most negative fixnum
// by -1.
void factor_vm::primitive_fixnum_divint() {
  fixnum y = untag_fixnum(ctx->pop());
  fixnum x = untag_fixnum(ctx->peek());
  fixnum result = x / y;
  if (result == -fixnum_min)
    // Does not allocate
    ctx->replace(from_signed_cell(-fixnum_min));
  else
    ctx->replace(tag_fixnum(result));
}

// does not allocate, even though from_signed_cell can allocate
void factor_vm::primitive_fixnum_divmod() {
  cell* s0 = (cell*)(ctx->datastack);
  cell* s1 = (cell*)(ctx->datastack - sizeof(cell));
  fixnum y = untag_fixnum(*s0);
  fixnum x = untag_fixnum(*s1);
  if (y == -1 && x == fixnum_min) {
    // Does not allocate
    *s1 = from_signed_cell(-fixnum_min);
    *s0 = tag_fixnum(0);
  } else {
    *s1 = tag_fixnum(x / y);
    *s0 = tag_fixnum(x % y);
  }
}


// If we're shifting right by n bits, we won't overflow as long as none of the
// high WORD_SIZE-TAG_BITS-n bits are set.
inline fixnum factor_vm::sign_mask(fixnum x) {
    return x >> (WORD_SIZE - 1);
}

inline fixnum factor_vm::branchless_max(fixnum x, fixnum y) {
  return (x - ((x - y) & sign_mask(x - y)));
}

inline fixnum factor_vm::branchless_abs(fixnum x) {
  return (x ^ sign_mask(x)) - sign_mask(x);
}

// Allocates memory
void factor_vm::primitive_fixnum_shift() {
  fixnum y = untag_fixnum(ctx->pop());
  fixnum x = untag_fixnum(ctx->peek());

  if (x == 0)
    return;
  else if (y < 0) {
    y = branchless_max(y, -WORD_SIZE + 1);
    ctx->replace(tag_fixnum(x >> -y));
    return;
  } else if (y < WORD_SIZE - TAG_BITS) {
    fixnum mask = -((fixnum)1 << (WORD_SIZE - 1 - TAG_BITS - y));
    if (!(branchless_abs(x) & mask)) {
      ctx->replace(tag_fixnum(x << y));
      return;
    }
  }

  ctx->replace(tag<bignum>(bignum_arithmetic_shift(fixnum_to_bignum(x), y)));
}

// Allocates memory
void factor_vm::primitive_fixnum_to_bignum() {
  ctx->replace(tag<bignum>(fixnum_to_bignum(untag_fixnum(ctx->peek()))));
}

// Allocates memory
void factor_vm::primitive_float_to_bignum() {
  ctx->replace(tag<bignum>(float_to_bignum(ctx->peek())));
}

#define POP_BIGNUMS(x, y)                \
  bignum* y = untag<bignum>(ctx->pop()); \
  bignum* x = untag<bignum>(ctx->peek());

void factor_vm::primitive_bignum_eq() {
  POP_BIGNUMS(x, y);
  ctx->replace(tag_boolean(bignum_equal_p(x, y)));
}

// Allocates memory
void factor_vm::primitive_bignum_add() {
  POP_BIGNUMS(x, y);
  ctx->replace(tag<bignum>(bignum_add(x, y)));
}

// Allocates memory
void factor_vm::primitive_bignum_subtract() {
  POP_BIGNUMS(x, y);
  ctx->replace(tag<bignum>(bignum_subtract(x, y)));
}

// Allocates memory
void factor_vm::primitive_bignum_multiply() {
  POP_BIGNUMS(x, y);
  ctx->replace(tag<bignum>(bignum_multiply(x, y)));
}

// Allocates memory
void factor_vm::primitive_bignum_divint() {
  POP_BIGNUMS(x, y);
  ctx->replace(tag<bignum>(bignum_quotient(x, y)));
}

// Allocates memory
void factor_vm::primitive_bignum_divmod() {
  cell* s0 = (cell*)(ctx->datastack);
  cell* s1 = (cell*)(ctx->datastack - sizeof(cell));
  bignum* y = untag<bignum>(*s0);
  bignum* x = untag<bignum>(*s1);
  bignum* q, *r;
  bignum_divide(x, y, &q, &r);
  *s1 = tag<bignum>(q);
  *s0 = bignum_maybe_to_fixnum(r);
}

void factor_vm::primitive_bignum_mod() {
  POP_BIGNUMS(x, y);
  cell val = bignum_maybe_to_fixnum(bignum_remainder(x, y));
  ctx->replace(val);
}

void factor_vm::primitive_bignum_gcd() {
  POP_BIGNUMS(x, y);
  ctx->replace(tag<bignum>(bignum_gcd(x, y)));
}

void factor_vm::primitive_bignum_and() {
  POP_BIGNUMS(x, y);
  ctx->replace(tag<bignum>(bignum_bitwise_and(x, y)));
}

void factor_vm::primitive_bignum_or() {
  POP_BIGNUMS(x, y);
  ctx->replace(tag<bignum>(bignum_bitwise_ior(x, y)));
}

void factor_vm::primitive_bignum_xor() {
  POP_BIGNUMS(x, y);
  ctx->replace(tag<bignum>(bignum_bitwise_xor(x, y)));
}

// Allocates memory
void factor_vm::primitive_bignum_shift() {
  fixnum y = untag_fixnum(ctx->pop());
  bignum* x = untag<bignum>(ctx->peek());
  ctx->replace(tag<bignum>(bignum_arithmetic_shift(x, y)));
}

void factor_vm::primitive_bignum_less() {
  POP_BIGNUMS(x, y);
  ctx->replace(tag_boolean(bignum_compare(x, y) == BIGNUM_COMPARISON_LESS));
}

void factor_vm::primitive_bignum_lesseq() {
  POP_BIGNUMS(x, y);
  ctx->replace(tag_boolean(bignum_compare(x, y) != BIGNUM_COMPARISON_GREATER));
}

void factor_vm::primitive_bignum_greater() {
  POP_BIGNUMS(x, y);
  ctx->replace(tag_boolean(bignum_compare(x, y) == BIGNUM_COMPARISON_GREATER));
}

void factor_vm::primitive_bignum_greatereq() {
  POP_BIGNUMS(x, y);
  ctx->replace(tag_boolean(bignum_compare(x, y) != BIGNUM_COMPARISON_LESS));
}

void factor_vm::primitive_bignum_not() {
  ctx->replace(tag<bignum>(bignum_bitwise_not(untag<bignum>(ctx->peek()))));
}

void factor_vm::primitive_bignum_bitp() {
  int bit = (int)to_fixnum(ctx->pop());
  bignum* x = untag<bignum>(ctx->peek());
  ctx->replace(tag_boolean(bignum_logbitp(bit, x)));
}

void factor_vm::primitive_bignum_log2() {
  ctx->replace(tag<bignum>(bignum_integer_length(untag<bignum>(ctx->peek()))));
}

// Allocates memory
void factor_vm::primitive_fixnum_to_float() {
  ctx->replace(allot_float(fixnum_to_float(ctx->peek())));
}

// Allocates memory
void factor_vm::primitive_format_float() {
  char* locale = alien_offset(ctx->pop());
  char* format = alien_offset(ctx->pop());
  fixnum precision = untag_fixnum(ctx->pop());
  fixnum width = untag_fixnum(ctx->pop());
  char* fill = alien_offset(ctx->pop());
  double value = untag_float_check(ctx->peek());
  std::ostringstream localized_stream;
  try {
    localized_stream.imbue(std::locale(locale));
  } catch (const runtime_error&) {
    byte_array* array = allot_byte_array(0);
    ctx->replace(tag<byte_array>(array));
    return;
  }
  switch (format[0]) {
    case 'f': localized_stream << std::fixed; break;
    case 'e': localized_stream << std::scientific; break;
  }
  if (isupper(format[0])) {
    localized_stream << std::uppercase;
  }
  if (fill[0] != '\0') {
    localized_stream << std::setfill(fill[0]);
  }
  if (width >= 0) {
    localized_stream << std::setw(static_cast<int>(width));
  }
  if (precision >= 0) {
    localized_stream << std::setprecision(static_cast<int>(precision));
  }
  localized_stream << value;
  const std::string& tmp = localized_stream.str();
  const char* cstr = tmp.c_str();
  size_t size = tmp.length();
  byte_array* array = allot_byte_array(size);
  memcpy(array->data<char>(), cstr, size);
  ctx->replace(tag<byte_array>(array));
}

#define POP_FLOATS(x, y)              \
  double y = untag_float(ctx->pop()); \
  double x = untag_float(ctx->peek());

void factor_vm::primitive_float_eq() {
  POP_FLOATS(x, y);
  ctx->replace(tag_boolean(x == y));
}

// Allocates memory
void factor_vm::primitive_float_add() {
  POP_FLOATS(x, y);
  ctx->replace(allot_float(x + y));
}

// Allocates memory
void factor_vm::primitive_float_subtract() {
  POP_FLOATS(x, y);
  ctx->replace(allot_float(x - y));
}

// Allocates memory
void factor_vm::primitive_float_multiply() {
  POP_FLOATS(x, y);
  ctx->replace(allot_float(x * y));
}

// Allocates memory
void factor_vm::primitive_float_divfloat() {
  POP_FLOATS(x, y);
  ctx->replace(allot_float(x / y));
}

void factor_vm::primitive_float_less() {
  POP_FLOATS(x, y);
  ctx->replace(tag_boolean(x < y));
}

void factor_vm::primitive_float_lesseq() {
  POP_FLOATS(x, y);
  ctx->replace(tag_boolean(x <= y));
}

void factor_vm::primitive_float_greater() {
  POP_FLOATS(x, y);
  ctx->replace(tag_boolean(x > y));
}

void factor_vm::primitive_float_greatereq() {
  POP_FLOATS(x, y);
  ctx->replace(tag_boolean(x >= y));
}

// Allocates memory
void factor_vm::primitive_float_bits() {
  ctx->replace(
      from_unsigned_cell(float_bits((float)untag_float_check(ctx->peek()))));
}

// Allocates memory
void factor_vm::primitive_bits_float() {
  ctx->replace(allot_float(bits_float((uint32_t)to_cell(ctx->peek()))));
}

void factor_vm::primitive_double_bits() {
  ctx->replace(from_unsigned_8(double_bits(untag_float_check(ctx->peek()))));
}

// Allocates memory
void factor_vm::primitive_bits_double() {
  ctx->replace(allot_float(bits_double(to_unsigned_8(ctx->peek()))));
}

// Cannot allocate.
#define CELL_TO_FOO(name, type, converter)              \
  type factor_vm::name(cell tagged) {                   \
    switch (TAG(tagged)) {                              \
      case FIXNUM_TYPE:                                 \
        return (type)untag_fixnum(tagged);              \
      case BIGNUM_TYPE:                                 \
        return converter(untag<bignum>(tagged));        \
      default:                                          \
        type_error(FIXNUM_TYPE, tagged);                \
        return 0; /* can't happen */                    \
    }                                                   \
  }                                                     \
  VM_C_API type name(cell tagged, factor_vm* parent) {  \
    return parent->name(tagged);                        \
  }

CELL_TO_FOO(to_fixnum, fixnum, bignum_to_fixnum)
CELL_TO_FOO(to_fixnum_strict, fixnum, bignum_to_fixnum_strict)
CELL_TO_FOO(to_cell, cell, bignum_to_cell)
CELL_TO_FOO(to_signed_8, int64_t, bignum_to_long_long)
CELL_TO_FOO(to_unsigned_8, uint64_t, bignum_to_ulong_long)

// Allocates memory
VM_C_API cell from_signed_cell(fixnum integer, factor_vm* parent) {
  return parent->from_signed_cell(integer);
}

// Allocates memory
VM_C_API cell from_unsigned_cell(cell integer, factor_vm* parent) {
  return parent->from_unsigned_cell(integer);
}

// Allocates memory
cell factor_vm::from_signed_8(int64_t n) {
  if (n < fixnum_min || n > fixnum_max)
    return tag<bignum>(long_long_to_bignum(n));
  else
    return tag_fixnum((fixnum)n);
}

VM_C_API cell from_signed_8(int64_t n, factor_vm* parent) {
  return parent->from_signed_8(n);
}

// Allocates memory
cell factor_vm::from_unsigned_8(uint64_t n) {
  if (n > (uint64_t)fixnum_max)
    return tag<bignum>(ulong_long_to_bignum(n));
  else
    return tag_fixnum((fixnum)n);
}

VM_C_API cell from_unsigned_8(uint64_t n, factor_vm* parent) {
  return parent->from_unsigned_8(n);
}

// Cannot allocate
float factor_vm::to_float(cell value) {
  return (float)untag_float_check(value);
}

// Cannot allocate
double factor_vm::to_double(cell value) { return untag_float_check(value); }

// The fixnum+, fixnum- and fixnum* primitives are defined in cpu_*.S. On
// overflow, they call these functions.
// Allocates memory
inline void factor_vm::overflow_fixnum_add(fixnum x, fixnum y) {
  ctx->replace(
      tag<bignum>(fixnum_to_bignum(untag_fixnum(x) + untag_fixnum(y))));
}

VM_C_API void overflow_fixnum_add(fixnum x, fixnum y, factor_vm* parent) {
  parent->overflow_fixnum_add(x, y);
}

// Allocates memory
inline void factor_vm::overflow_fixnum_subtract(fixnum x, fixnum y) {
  ctx->replace(
      tag<bignum>(fixnum_to_bignum(untag_fixnum(x) - untag_fixnum(y))));
}

VM_C_API void overflow_fixnum_subtract(fixnum x, fixnum y, factor_vm* parent) {
  parent->overflow_fixnum_subtract(x, y);
}

// Allocates memory
inline void factor_vm::overflow_fixnum_multiply(fixnum x, fixnum y) {
  data_root<bignum> bx(fixnum_to_bignum(x), this);
  data_root<bignum> by(fixnum_to_bignum(y), this);
  cell ret = tag<bignum>(bignum_multiply(bx.untagged(), by.untagged()));
  ctx->replace(ret);
}

VM_C_API void overflow_fixnum_multiply(fixnum x, fixnum y, factor_vm* parent) {
  parent->overflow_fixnum_multiply(x, y);
}

}
