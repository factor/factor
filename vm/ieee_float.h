#ifndef FACTOR_IEEE_FLOAT_H
#define FACTOR_IEEE_FLOAT_H
// C ABI: scalar bit patterns in, scalar outputs through pointers. Output
// pointers must be valid and distinct. Errors leave every output unchanged.
#include <stdint.h>
#if defined(_WIN32) && defined(FACTOR_FP_EXPORTS)
#define FACTOR_FP_API __declspec(dllexport)
#elif defined(__GNUC__)
#define FACTOR_FP_API __attribute__((visibility("default")))
#else
#define FACTOR_FP_API
#endif
#ifdef __cplusplus
extern "C" {
#endif
enum factor_fp_status { FACTOR_FP_OK = 0, FACTOR_FP_BAD_ARGUMENT = 1, FACTOR_FP_BAD_MODE = 2 };
enum factor_fp_rounding {
  FACTOR_FP_NEAREST_EVEN = 0, FACTOR_FP_TOWARD_ZERO = 1, FACTOR_FP_DOWNWARD = 2,
  FACTOR_FP_UPWARD = 3, FACTOR_FP_NEAREST_AWAY = 4
};
enum factor_fp_exception {
  FACTOR_FP_INEXACT = 1, FACTOR_FP_UNDERFLOW = 2, FACTOR_FP_OVERFLOW = 4,
  FACTOR_FP_DIVIDE_BY_ZERO = 8, FACTOR_FP_INVALID = 16
};
enum factor_fp_operation {
  FACTOR_FP_ADD = 0, FACTOR_FP_SUBTRACT = 1, FACTOR_FP_MULTIPLY = 2,
  FACTOR_FP_DIVIDE = 3, FACTOR_FP_REMAINDER = 4
};
enum factor_fp_comparison { FACTOR_FP_LESS = 0, FACTOR_FP_EQUAL = 1, FACTOR_FP_GREATER = 2, FACTOR_FP_UNORDERED = 3 };
enum factor_fp_comparison_policy { FACTOR_FP_QUIET = 0, FACTOR_FP_SIGNALING = 1 };
#define FACTOR_FP_DECLARE(WIDTH, UINT) \
FACTOR_FP_API int factor_fp##WIDTH##_binary(uint8_t operation, UINT a, UINT b, uint8_t mode, UINT* value, uint8_t* flags); \
FACTOR_FP_API int factor_fp##WIDTH##_sqrt(UINT a, uint8_t mode, UINT* value, uint8_t* flags); \
FACTOR_FP_API int factor_fp##WIDTH##_fma(UINT a, UINT b, UINT c, uint8_t mode, UINT* value, uint8_t* flags); \
FACTOR_FP_API int factor_fp##WIDTH##_compare(UINT a, UINT b, uint8_t policy, uint8_t* order, uint8_t* flags);
FACTOR_FP_DECLARE(32, uint32_t)
FACTOR_FP_DECLARE(64, uint64_t)
#undef FACTOR_FP_DECLARE
FACTOR_FP_API int factor_fp32_to_fp64(uint32_t a, uint8_t mode, uint64_t* value, uint8_t* flags);
FACTOR_FP_API int factor_fp64_to_fp32(uint64_t a, uint8_t mode, uint32_t* value, uint8_t* flags);
#define FACTOR_FP_INTEGER(WIDTH, UINT, NAME, INT) \
FACTOR_FP_API int factor_fp##WIDTH##_from_##NAME(INT a, uint8_t mode, UINT* value, uint8_t* flags); \
FACTOR_FP_API int factor_fp##WIDTH##_to_##NAME(UINT a, uint8_t mode, INT* value, uint8_t* valid, uint8_t* flags);
#define FACTOR_FP_INTEGERS(WIDTH, UINT) \
FACTOR_FP_INTEGER(WIDTH, UINT, i32, int32_t) \
FACTOR_FP_INTEGER(WIDTH, UINT, u32, uint32_t) \
FACTOR_FP_INTEGER(WIDTH, UINT, i64, int64_t) \
FACTOR_FP_INTEGER(WIDTH, UINT, u64, uint64_t)
FACTOR_FP_INTEGERS(32, uint32_t)
FACTOR_FP_INTEGERS(64, uint64_t)
#undef FACTOR_FP_INTEGERS
#undef FACTOR_FP_INTEGER
#ifdef __cplusplus
}
#endif
#endif
