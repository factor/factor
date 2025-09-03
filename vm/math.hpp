namespace factor {

static const fixnum fixnum_max =
    (((fixnum)1 << (WORD_SIZE - TAG_BITS - 1)) - 1);
static const fixnum fixnum_min = (-((fixnum)1 << (WORD_SIZE - TAG_BITS - 1)));
static const fixnum array_size_max = ((cell)1 << (WORD_SIZE - TAG_BITS - 2));

// Allocates memory
inline cell factor_vm::from_signed_cell(fixnum x) {
  if (x < fixnum_min || x > fixnum_max)
    return tag<bignum>(fixnum_to_bignum(x));
  return tag_fixnum(x);
}

// Allocates memory
inline cell factor_vm::from_unsigned_cell(cell x) {
  if (x > (cell)fixnum_max)
    return tag<bignum>(cell_to_bignum(x));
  return tag_fixnum(x);
}

// Allocates memory
inline cell factor_vm::allot_float(double n) {
  boxed_float* flo = allot<boxed_float>(sizeof(boxed_float));
  flo->n = n;
  return tag(flo);
}

// Allocates memory
inline bignum* factor_vm::float_to_bignum(cell tagged) {
  return double_to_bignum(untag_float(tagged));
}

inline double factor_vm::untag_float(cell tagged) {
  return untag<boxed_float>(tagged)->n;
}

inline double factor_vm::untag_float_check(cell tagged) {
  return untag_check<boxed_float>(tagged)->n;
}

inline fixnum factor_vm::float_to_fixnum(cell tagged) {
  return (fixnum)untag_float(tagged);
}

inline double factor_vm::fixnum_to_float(cell tagged) {
  return (double)untag_fixnum(tagged);
}

inline cell factor_vm::unbox_array_size() {
  cell obj = ctx->pop();
  fixnum n = to_fixnum_strict(obj);
  if (n >= 0 && n < (fixnum)array_size_max) {
    return n;
  }
  general_error(ERROR_ARRAY_SIZE, obj, tag_fixnum(array_size_max));
  return 0; // can't happen
}

VM_C_API cell from_signed_cell(fixnum integer, factor_vm* vm);
VM_C_API cell from_unsigned_cell(cell integer, factor_vm* vm);
VM_C_API cell from_signed_8(int64_t n, factor_vm* vm);
VM_C_API cell from_unsigned_8(uint64_t n, factor_vm* vm);
VM_C_API cell from_signed_4(int32_t n, factor_vm* vm);
VM_C_API cell from_unsigned_4(uint32_t n, factor_vm* vm);

VM_C_API int64_t to_signed_8(cell obj, factor_vm* parent);
VM_C_API uint64_t to_unsigned_8(cell obj, factor_vm* parent);
VM_C_API int32_t to_signed_4(cell obj, factor_vm* parent);
VM_C_API uint32_t to_unsigned_4(cell obj, factor_vm* parent);

VM_C_API fixnum to_fixnum(cell tagged, factor_vm* vm);
VM_C_API cell to_cell(cell tagged, factor_vm* vm);

VM_C_API void overflow_fixnum_add(fixnum x, fixnum y, factor_vm* parent);
VM_C_API void overflow_fixnum_subtract(fixnum x, fixnum y, factor_vm* parent);
VM_C_API void overflow_fixnum_multiply(fixnum x, fixnum y, factor_vm* parent);

}
