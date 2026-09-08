/* Independent C varargs callees, shared by all native test platforms. */
#include <stdarg.h>
#ifndef FACTOR_EXPORT
#define FACTOR_EXPORT
#endif
#if defined(_MSC_VER)
#define VAROUT_NOINLINE __declspec(noinline)
#else
#define VAROUT_NOINLINE __attribute__((noinline))
#endif
struct varout_pair { double x, y; };
struct varout_hfa { double x, y, z; };
struct varout_small_hfa { float x, y; };

FACTOR_EXPORT VAROUT_NOINLINE double varout_mixed(float first, double second, int tag, ...) {
  va_list ap; va_start(ap, tag);
  int i = va_arg(ap, int); double d = va_arg(ap, double);
  long long l = va_arg(ap, long long); double e = va_arg(ap, double);
  int j = va_arg(ap, int); double f = va_arg(ap, double);
  va_end(ap);
  return first + 2*second + 3*tag + 4*i + 5*d + 6*l + 7*e + 8*j + 9*f;
}
FACTOR_EXPORT VAROUT_NOINLINE double varout_hfas(struct varout_small_hfa named, int tag, ...) {
  va_list ap; va_start(ap, tag);
  struct varout_pair p = va_arg(ap, struct varout_pair);
  struct varout_hfa h = va_arg(ap, struct varout_hfa);
  double d = va_arg(ap, double); va_end(ap);
  return named.x + 2*named.y + 3*tag + 4*p.x + 5*p.y + 6*h.x + 7*h.y + 8*h.z + 9*d;
}
FACTOR_EXPORT VAROUT_NOINLINE double varout_split(int a, int b, int c, int d, int e, int f, int g, ...) {
  va_list ap; va_start(ap, g);
  struct varout_pair p = va_arg(ap, struct varout_pair);
  double tail = va_arg(ap, double); va_end(ap);
  return a + 2*b + 3*c + 4*d + 5*e + 6*f + 7*g + 8*p.x + 9*p.y + 10*tail;
}
FACTOR_EXPORT VAROUT_NOINLINE struct varout_hfa varout_return(int tag, ...) {
  va_list ap; va_start(ap, tag);
  struct varout_hfa h = va_arg(ap, struct varout_hfa); va_end(ap);
  h.x += tag; h.y += 2*tag; h.z += 3*tag; return h;
}
FACTOR_EXPORT VAROUT_NOINLINE double varout_control(void) {
  struct varout_small_hfa n = {1,2};
  struct varout_pair p = {4,5}; struct varout_hfa h = {6,7,8};
  return varout_mixed(1,2,3,4,5.0,(long long)6,7.0,8,9.0)
      + varout_hfas(n,3,p,h,9.0);
}

/* LLVM's Windows C caller puts the whole final composite on the stack,
 * while its own va_arg reader consumes X7 + stack. Keep this independent
 * control available for MSVC and explicitly report the affected toolchain. */
FACTOR_EXPORT VAROUT_NOINLINE double varout_split_control(void) {
  struct varout_pair p = {4,5};
  return varout_split(1,2,3,4,5,6,7,p,10.0);
}
FACTOR_EXPORT int varout_split_caller_supported(void) {
#if defined(_WIN32) && defined(__aarch64__) && defined(__clang__)
  return 0;
#else
  return 1;
#endif
}

#if defined(__aarch64__) && defined(__clang__) && __clang_major__ >= 18
#define VAROUT_SMALL(T, name) \
FACTOR_EXPORT unsigned long long name(T named, int count, ...) { \
  va_list ap; va_start(ap, count); \
  unsigned short bits; __builtin_memcpy(&bits, &named, 2); \
  unsigned long long sum = bits; \
  for (int i = 0; i < count; ++i) { \
    T value = va_arg(ap, T); __builtin_memcpy(&bits, &value, 2); \
    sum += (unsigned long long)bits * (i + 2); \
  } \
  va_end(ap); return sum; \
}
VAROUT_SMALL(_Float16, varout_half_bits)
VAROUT_SMALL(__bf16, varout_bfloat_bits)
#undef VAROUT_SMALL
#endif

#if defined(__clang__) || defined(__GNUC__)
typedef float varout_vector __attribute__((vector_size(16)));
struct varout_hva { varout_vector a, b; };
FACTOR_EXPORT VAROUT_NOINLINE double varout_vector_args(int tag, ...) {
  va_list ap; va_start(ap, tag);
  varout_vector a = va_arg(ap, varout_vector);
  struct varout_hva h = va_arg(ap, struct varout_hva);
  double tail = va_arg(ap, double); va_end(ap);
  return tag + a[0] + 2*a[1] + 3*a[2] + 4*a[3]
      + h.a[0] + 2*h.a[1] + 3*h.a[2] + 4*h.a[3]
      + h.b[0] + 2*h.b[1] + 3*h.b[2] + 4*h.b[3] + tail;
}
#endif
