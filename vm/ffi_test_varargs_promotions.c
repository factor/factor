/* C default promotions are applied after conversion to the source type. */
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#ifndef FACTOR_EXPORT
#define FACTOR_EXPORT
#endif

#if defined(__GNUC__) || defined(__clang__)
#define VAP_PACKED __attribute__((packed))
#else
#define VAP_PACKED
#endif
enum VAP_PACKED vap_signed_enum { vap_negative = -7 };
enum VAP_PACKED vap_unsigned_enum { vap_positive = 65530 };

FACTOR_EXPORT int vap_read_integer(int tag, ...) {
  (void)tag;
  va_list ap; va_start(ap, tag);
  int value = va_arg(ap, int);
  va_end(ap); return value;
}

FACTOR_EXPORT double vap_read_float(int tag, ...) {
  (void)tag;
  va_list ap; va_start(ap, tag);
  double value = va_arg(ap, double);
  va_end(ap); return value;
}

/* Keep the preceding call's complete anonymous stack slots observable. */
FACTOR_EXPORT long long vap_poison(int tag, ...) {
  (void)tag;
  va_list ap; va_start(ap, tag);
  long long value = va_arg(ap, long long);
  va_end(ap); return value;
}

FACTOR_EXPORT int vap_control_integer(int which) {
  switch (which) {
    case 0: return vap_read_integer(0, (bool)true);
    case 1: return vap_read_integer(0, (bool)false);
    case 2: {
      int source = 255;
      return vap_read_integer(0, (signed char)source);
    }
    case 3: return vap_read_integer(0, (unsigned char)-1);
    case 4: return vap_read_integer(0, (unsigned short)-1);
    case 5: return vap_read_integer(0, (enum vap_signed_enum)vap_negative);
    default: return vap_read_integer(0, (enum vap_unsigned_enum)vap_positive);
  }
}

FACTOR_EXPORT double vap_control_float(void) {
  return vap_read_float(0, (float)0.1);
}

typedef double (*vap_reader)(int, ...);
FACTOR_EXPORT double vap_call_reader(vap_reader callback) {
  return callback(1, (bool)true, (enum vap_signed_enum)vap_negative,
                  (enum vap_unsigned_enum)vap_positive, (float)0.1);
}
