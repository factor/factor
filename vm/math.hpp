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
inline cell factor_vm::allot_float(vm_float n) {
  boxed_float* flo = allot<boxed_float>(sizeof(boxed_float));
#if defined(FACTOR_INVERSE_NAN_ENCODING)
  uint64_t bits = inverse_canonical_double_bits(double_bits(n));
  memcpy(&flo->n, &bits, sizeof(bits));
#else
  flo->n = n;
#endif
  return tag(flo);
}

inline cell factor_vm::allot_float_bits(uint64_t bits) {
  boxed_float* flo = allot<boxed_float>(sizeof(boxed_float));
  memcpy(static_cast<void*>(&flo->n), &bits, sizeof(bits));
  return tag(flo);
}

#if defined(FACTOR_INTEGER_ONLY)
inline cell factor_vm::allot_float(float n) {
  (void)n;
  general_error(ERROR_FLOAT_UNSUPPORTED, false_object, false_object);
  return false_object;
}
inline cell factor_vm::allot_float(double n) {
  (void)n;
  general_error(ERROR_FLOAT_UNSUPPORTED, false_object, false_object);
  return false_object;
}
#elif defined(FACTOR_INVERSE_NAN_ENCODING)
inline cell factor_vm::allot_float(float n) {
  return allot_float_bits(widen_float_bits(inverse_canonical_float_bits(float_bits(n))));
}
#elif defined(__vax__)
// Foreign values retain the native F/D ABI. No native floating arithmetic is
// needed to box them, including dirty zero and reserved-operand encodings.
inline cell factor_vm::allot_float(float n) {
  uint32_t bits = 0;
  if (vax_f_to_ieee(&n, bits) == vax_float_conversion::reserved_operand)
    general_error(ERROR_FFI, false_object, false_object);
  return allot_float(vm_float::from_float_bits(bits));
}

inline cell factor_vm::allot_float(double n) {
  uint64_t bits = 0;
#if defined(__GFLOAT__)
#error "The VAX VM uses NetBSD's default D-floating foreign ABI"
#endif
  if (vax_d_to_ieee(&n, bits) == vax_float_conversion::reserved_operand)
    general_error(ERROR_FFI, false_object, false_object);
  return allot_float_bits(bits);
}
#endif

// Allocates memory
inline bignum* factor_vm::float_to_bignum(cell tagged) {
  return double_to_bignum(untag_float(tagged));
}

inline vm_float factor_vm::untag_float(cell tagged) {
#if defined(FACTOR_INVERSE_NAN_ENCODING)
  uint64_t bits;
  memcpy(&bits, &untag<boxed_float>(tagged)->n, sizeof(bits));
  return bits_double(inverse_native_double_bits(bits));
#else
  return untag<boxed_float>(tagged)->n;
#endif
}

inline vm_float factor_vm::untag_float_check(cell tagged) {
#if defined(FACTOR_INVERSE_NAN_ENCODING)
  uint64_t bits;
  memcpy(&bits, &untag_check<boxed_float>(tagged)->n, sizeof(bits));
  return bits_double(inverse_native_double_bits(bits));
#else
  return untag_check<boxed_float>(tagged)->n;
#endif
}

inline fixnum factor_vm::float_to_fixnum(cell tagged) {
#if defined(FACTOR_INTEGER_ONLY)
  (void)tagged;
  general_error(ERROR_FLOAT_UNSUPPORTED, false_object, false_object);
  return 0;
#else
#if defined(__vax__)
  return (fixnum)vm_float_to_signed(untag_float(tagged));
#else
  return (fixnum)untag_float(tagged);
#endif
#endif
}

inline vm_float factor_vm::fixnum_to_float(cell tagged) {
#if defined(FACTOR_INTEGER_ONLY)
  (void)tagged;
  general_error(ERROR_FLOAT_UNSUPPORTED, false_object, false_object);
  return vm_float{0};
#else
  return vm_float_from_signed(untag_fixnum(tagged));
#endif
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
VM_C_API void divide_by_zero(factor_vm* parent);

}
