/* Copyright (C) 2026 Doug Coleman. BSD license: https://factorcode.org/license.txt */
/* Independent scalar ABI oracle. Keep unsupported toolchains buildable.
 * Clang 18+ AArch64 supplies arithmetic _Float16 and __bf16. A successful
 * capability query is required before the Factor tests bind these exports.
 */
#include <stdint.h>
FACTOR_EXPORT int ffi_test_small_floats_available(void);
#if defined(__aarch64__) && defined(__clang__) && __clang_major__ >= 18
int ffi_test_small_floats_available(void) { return 1; }
#define DEFINE(T,N) \
FACTOR_EXPORT T N##_identity(T x) { return x; } \
FACTOR_EXPORT uint16_t N##_bits(T x) { uint16_t u; memcpy(&u,&x,2); return u; } \
FACTOR_EXPORT T N##_from_bits(uint16_t u) { T x; memcpy(&x,&u,2); return x; } \
FACTOR_EXPORT T N##_convert(double x) { return (T)x; } \
FACTOR_EXPORT T N##_callback(T (*f)(T), T x) { return f(x); } \
FACTOR_EXPORT double N##_mixed(int a, T b, double c, T d, int e) { return a+(double)b+c+(double)d+e; } \
FACTOR_EXPORT T N##_overflow(T a,T b,T c,T d,T e,T f,T g,T h,T i,T j) { return a+b+c+d+e+f+g+h+i+j; } \
FACTOR_EXPORT double N##_varargs(int ignored, ...) { \
  (void)ignored; va_list ap; va_start(ap, ignored); \
  T a = va_arg(ap, T); T b = va_arg(ap, T); \
  int c = va_arg(ap, int); double d = va_arg(ap, double); \
  va_end(ap); return (double)a + (double)b + c + d; } \
FACTOR_EXPORT T N##_overflow_callback(T (*f)(T,T,T,T,T,T,T,T,T,T)) { return f(1,2,3,4,5,6,7,8,9,10); }
DEFINE(_Float16,half)
DEFINE(__bf16,bfloat)
/* ABI padding bits above H0 are unspecified, not a numeric single float. */
FACTOR_EXPORT _Float16 half_dirty_result(void) {
  unsigned int raw = 0xa5a53c00;
  _Float16 x;
  __asm__("fmov %s0, %w1" : "=w"(x) : "r"(raw));
  return x;
}
FACTOR_EXPORT __bf16 bfloat_dirty_result(void) {
  unsigned int raw = 0xa5a53f80;
  __bf16 x;
  __asm__("fmov %s0, %w1" : "=w"(x) : "r"(raw));
  return x;
}
typedef struct { _Float16 a; __bf16 b; } mixed_small;
FACTOR_EXPORT double mixed_small_sum(mixed_small x) { return (double)x.a + (double)x.b; }

#undef DEFINE
#else
int ffi_test_small_floats_available(void) { return 0; }
#endif
