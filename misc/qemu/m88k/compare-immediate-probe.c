#ifndef M88K_COMPARE_DRIVER
#define COMPARE(name, value) int name(int input) { return input == (value); }
COMPARE(eq_m32768, -32768)
COMPARE(eq_m42, -42)
COMPARE(eq_m1, -1)
COMPARE(eq_0, 0)
COMPARE(eq_32767, 32767)
COMPARE(eq_32768, 32768)
COMPARE(eq_65535, 65535)
COMPARE(eq_65536, 65536)
#else
#include <stdio.h>
#define DECLARE(name) extern int name(int);
DECLARE(eq_m32768)
DECLARE(eq_m42)
DECLARE(eq_m1)
DECLARE(eq_0)
DECLARE(eq_32767)
DECLARE(eq_32768)
DECLARE(eq_65535)
DECLARE(eq_65536)

int main(void) {
  const int values[] = {-32768, -42, -1, 0, 32767, 32768, 65535, 65536};
  int (*const funcs[])(int) = {eq_m32768, eq_m42, eq_m1, eq_0,
                              eq_32767, eq_32768, eq_65535, eq_65536};
  int failures = 0;
  for (unsigned i = 0; i < sizeof values / sizeof *values; ++i) {
    int match = funcs[i](values[i]);
    int low = values[i] & 65535;
    int truncated = funcs[i](low);
    int expected = low == values[i];
    printf("compare %d match=%d low=%d expected-low=%d\n",
           values[i], match, truncated, expected);
    failures += match != 1 || truncated != expected;
  }
  return failures != 0;
}
#endif
