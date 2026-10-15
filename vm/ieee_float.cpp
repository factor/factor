#define FACTOR_FP_EXPORTS 1
#include "ieee_float.h"
#include "ieee_float.hpp"
namespace {
using namespace factor::fp;
template<class T> int validate(uint8_t mode, T* value, uint8_t* flags) noexcept {
  if (!value || !flags) return FACTOR_FP_BAD_ARGUMENT;
  return mode <= 4 ? FACTOR_FP_OK : FACTOR_FP_BAD_MODE;
}
template<class F> int binary_op(uint8_t op, typename F::storage_type a, typename F::storage_type b,
                              uint8_t mode, typename F::storage_type* value, uint8_t* flags) noexcept {
  int error = validate(mode, value, flags); if (error) return error;
  if (op > FACTOR_FP_REMAINDER) return FACTOR_FP_BAD_ARGUMENT;
  F x{a}, y{b}; rounding_mode rounding = rounding_mode(mode);
  result<F> r;
  switch (op) {
    case FACTOR_FP_ADD: r = add(x, y, rounding); break;
    case FACTOR_FP_SUBTRACT: r = subtract(x, y, rounding); break;
    case FACTOR_FP_MULTIPLY: r = multiply(x, y, rounding); break;
    case FACTOR_FP_DIVIDE: r = divide(x, y, rounding); break;
    default: r = remainder(x, y, rounding); break;
  }
  *value = r.value.bits; *flags = r.raised; return FACTOR_FP_OK;
}
}
extern "C" {
#define FACTOR_FP_DEFINE(WIDTH, UINT, F) \
int factor_fp##WIDTH##_binary(uint8_t op, UINT a, UINT b, uint8_t mode, UINT* value, uint8_t* flags) { \
  return binary_op<F>(op, a, b, mode, value, flags); \
} \
int factor_fp##WIDTH##_sqrt(UINT a, uint8_t mode, UINT* value, uint8_t* flags) { \
  int error = validate(mode, value, flags); if (error) return error; \
  auto r = factor::fp::sqrt(F{a}, rounding_mode(mode)); \
  *value = r.value.bits; *flags = r.raised; return FACTOR_FP_OK; \
} \
int factor_fp##WIDTH##_fma(UINT a, UINT b, UINT c, uint8_t mode, UINT* value, uint8_t* flags) { \
  int error = validate(mode, value, flags); if (error) return error; \
  auto r = fma(F{a}, F{b}, F{c}, rounding_mode(mode)); \
  *value = r.value.bits; *flags = r.raised; return FACTOR_FP_OK; \
} \
int factor_fp##WIDTH##_compare(UINT a, UINT b, uint8_t policy, uint8_t* order, uint8_t* flags) { \
  if (!order || !flags || policy > 1) return FACTOR_FP_BAD_ARGUMENT; \
  auto r = compare(F{a}, F{b}, comparison_policy(policy)); \
  *order = uint8_t(r.value); *flags = r.raised; return FACTOR_FP_OK; \
}
FACTOR_FP_DEFINE(32, uint32_t, binary32)
FACTOR_FP_DEFINE(64, uint64_t, binary64)
#undef FACTOR_FP_DEFINE
int factor_fp32_to_fp64(uint32_t a, uint8_t mode, uint64_t* value, uint8_t* flags) {
  int error = validate(mode, value, flags); if (error) return error;
  auto r = convert<binary64>(binary32{a}, rounding_mode(mode));
  *value = r.value.bits; *flags = r.raised; return FACTOR_FP_OK;
}
int factor_fp64_to_fp32(uint64_t a, uint8_t mode, uint32_t* value, uint8_t* flags) {
  int error = validate(mode, value, flags); if (error) return error;
  auto r = convert<binary32>(binary64{a}, rounding_mode(mode));
  *value = r.value.bits; *flags = r.raised; return FACTOR_FP_OK;
}
#define FACTOR_FP_INTEGER(WIDTH, UINT, F, NAME, INT) \
int factor_fp##WIDTH##_from_##NAME(INT a, uint8_t mode, UINT* value, uint8_t* flags) { \
  int error = validate(mode, value, flags); if (error) return error; \
  auto r = from_integer<F>(a, rounding_mode(mode)); \
  *value = r.value.bits; *flags = r.raised; return FACTOR_FP_OK; \
} \
int factor_fp##WIDTH##_to_##NAME(UINT a, uint8_t mode, INT* value, uint8_t* valid, uint8_t* flags) { \
  int error = validate(mode, value, flags); if (error) return error; \
  if (!valid) return FACTOR_FP_BAD_ARGUMENT; \
  auto r = to_integer<INT>(F{a}, rounding_mode(mode)); \
  *value = r.value.value; *valid = uint8_t(r.value.valid); *flags = r.raised; return FACTOR_FP_OK; \
}
#define FACTOR_FP_INTEGERS(WIDTH, UINT, F) \
FACTOR_FP_INTEGER(WIDTH, UINT, F, i32, int32_t) \
FACTOR_FP_INTEGER(WIDTH, UINT, F, u32, uint32_t) \
FACTOR_FP_INTEGER(WIDTH, UINT, F, i64, int64_t) \
FACTOR_FP_INTEGER(WIDTH, UINT, F, u64, uint64_t)
FACTOR_FP_INTEGERS(32, uint32_t, binary32)
FACTOR_FP_INTEGERS(64, uint64_t, binary64)
#undef FACTOR_FP_INTEGERS
#undef FACTOR_FP_INTEGER
}
