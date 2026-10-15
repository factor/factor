/* Run with both native GCC and modern Clang against the native libc. */
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

static int format(char *out, unsigned size, const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  int result = vsnprintf(out, size, fmt, args);
  va_end(args);
  return result;
}

static int words(int first, ...) {
  va_list args;
  va_start(args, first);
  int ok = first == 11;
  for (int expected = 22; expected <= 110; expected += 11)
    ok &= va_arg(args, int) == expected;
  va_end(args);
  return ok;
}

static int pairs(int first, ...) {
  va_list args;
  va_start(args, first);
  int ok = first == 11;
  ok &= va_arg(args, unsigned long long) == 0x123456789abcdef0ULL;
  ok &= va_arg(args, int) == 22;
  ok &= va_arg(args, unsigned long long) == 0xfedcba9876543210ULL;
  ok &= va_arg(args, int) == 33;
  ok &= va_arg(args, unsigned long long) == 0x1122334455667788ULL;
  va_end(args);
  return ok;
}

/* zero is emitted from varargs-zero.ll: no named argument consumes a register. */
extern int zero(int, int);

static int seven(int a, int b, int c, int d, int e, int f, int g, ...) {
  va_list args;
  va_start(args, g);
  int ok = a + b + c + d + e + f + g == 28;
  ok &= va_arg(args, int) == 88;
  ok &= va_arg(args, int) == 99;
  va_end(args);
  return ok;
}

static int cross(int a, int b, int c, int d, int e, int f, int g, ...) {
  va_list args;
  va_start(args, g);
  int ok = a + b + c + d + e + f + g == 28;
  ok &= va_arg(args, unsigned long long) == 0x123456789abcdef0ULL;
  ok &= va_arg(args, int) == 42;
  va_end(args);
  return ok;
}

static int eight(int a, int b, int c, int d, int e, int f, int g, int h, ...) {
  va_list args;
  va_start(args, h);
  int ok = a + b + c + d + e + f + g + h == 36;
  ok &= va_arg(args, int) == 1234;
  va_end(args);
  return ok;
}

int main(void) {
  char out[80];
  format(out, sizeof out, "%d,%u,%lu", -42, 1234u, 0x12345678ul);
  int bridge = strcmp(out, "-42,1234,305419896") == 0;
  int ints = words(11, 22, 33, 44, 55, 66, 77, 88, 99, 110);
  int wide = pairs(11, 0x123456789abcdef0ULL, 22,
                   0xfedcba9876543210ULL, 33, 0x1122334455667788ULL);
  int r0 = zero(1234, 42);
  int r7 = seven(1, 2, 3, 4, 5, 6, 7, 88, 99);
  int spill = cross(1, 2, 3, 4, 5, 6, 7, 0x123456789abcdef0ULL, 42);
  int r8 = eight(1, 2, 3, 4, 5, 6, 7, 8, 1234);
  printf("numeric=%s bridge=%d words=%d pairs=%d r0=%d r7=%d cross=%d r8=%d\n",
         out, bridge, ints, wide, r0, r7, spill, r8);
  return !(bridge && ints && wide && r0 && r7 && spill && r8);
}
