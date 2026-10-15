/* Compile with GCC -O2 -mabi=64 -EB -S to inspect the independent N64 ABI.
   Scalar int extracts a1's low word; a one-int struct extracts its high word. */
#include <stdarg.h>

struct tiny { int x; };

int read_int(int marker, ...) {
  va_list ap;
  va_start(ap, marker);
  int value = va_arg(ap, int);
  va_end(ap);
  return value;
}

int read_tiny(int marker, ...) {
  va_list ap;
  va_start(ap, marker);
  struct tiny value = va_arg(ap, struct tiny);
  va_end(ap);
  return value.x;
}
