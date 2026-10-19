#include <stdio.h>

#ifndef M88K_INTEROP_CALLER
#include <stdarg.h>
#include <string.h>

int interop_cross(int a, int b, int c, int d, int e, int f, int g, ...) {
  va_list ap;
  unsigned state[3], before, after_pair, after_int;
  va_start(ap, g);
  memcpy(state, &ap, sizeof state);
  before = state[0];
  unsigned long long wide = va_arg(ap, unsigned long long);
  memcpy(state, &ap, sizeof state);
  after_pair = state[0];
  int last = va_arg(ap, int);
  memcpy(state, &ap, sizeof state);
  after_int = state[0];
  va_end(ap);
  printf("cross index=%u/%u/%u pair=%08x:%08x last=%d\n",
         before, after_pair, after_int, (unsigned)(wide >> 32),
         (unsigned)wide, last);
  return a + b + c + d + e + f + g != 28 ||
         wide != 0x123456789abcdef0ULL || last != 42;
}

int interop_fixed(int a, int b, int c, int d, int e, int f, int g,
                  unsigned long long wide, int last) {
  printf("fixed pair=%08x:%08x last=%d\n",
         (unsigned)(wide >> 32), (unsigned)wide, last);
  return a + b + c + d + e + f + g != 28 ||
         wide != 0x123456789abcdef0ULL || last != 42;
}
#else
extern int interop_cross(int, int, int, int, int, int, int, ...);
extern int interop_fixed(int, int, int, int, int, int, int,
                         unsigned long long, int);

int main(void) {
  int cross = interop_cross(1, 2, 3, 4, 5, 6, 7, 0x123456789abcdef0ULL, 42);
  int fixed = interop_fixed(1, 2, 3, 4, 5, 6, 7, 0x123456789abcdef0ULL, 42);
  printf("interop cross=%d fixed=%d\n", cross, fixed);
  return cross || fixed;
}
#endif
