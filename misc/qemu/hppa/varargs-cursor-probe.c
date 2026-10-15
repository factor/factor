/* Independent GNU PA32 va_list oracle for the Factor cursor reader.
 * Mirrors must populate original native SP -36/-40/-44/-48 before a
 * variadic Factor callback enters C begin_callback. This probe validates
 * GNU slot arithmetic; it does not execute a complete Factor callback.
 */
#include <assert.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
struct three { unsigned char bytes[3]; };
struct seven { unsigned char bytes[7]; };
struct large { int a, b, c; };
static void mixed(int named, ...) {
  assert(named == 9);
  va_list args, copy; va_start(args, named); va_copy(copy, args);
  uintptr_t pointer = (uintptr_t)args;
  pointer -= 4;
  int a = va_arg(args, int); assert(a == -7 && *(int*)pointer == a);
  assert(va_arg(copy, int) == a); va_end(copy);
  pointer = (pointer - 8) & ~(uintptr_t)7;
  double b = va_arg(args, double); assert(b == 3.5 && *(double*)pointer == b);
  pointer -= 4;
  int c = va_arg(args, int); assert(c == 42 && *(int*)pointer == c);
  assert((uintptr_t)args == pointer); va_end(args);
}
static void aggregates(int named, ...) {
  assert(named == 9);
  va_list args; va_start(args, named); uintptr_t pointer = (uintptr_t)args;
  const struct three expected3 = {{1, 17, 255}};
  const struct seven expected7 = {{2, 3, 5, 7, 11, 13, 19}};
  const struct large expected_large = {-123, 456, -789};
  pointer -= 4;
  struct three a = va_arg(args, struct three);
  assert(!memcmp(&a, &expected3, 3) && !memcmp((void*)(pointer + 1), &a, 3));
  pointer = (pointer - 8) & ~(uintptr_t)7;
  struct seven b = va_arg(args, struct seven);
  assert(!memcmp(&b, &expected7, 7) && !memcmp((void*)(pointer + 1), &b, 7));
  pointer -= 4;
  struct large c = va_arg(args, struct large);
  assert(!memcmp(&c, &expected_large, sizeof c));
  assert(!memcmp(*(void**)pointer, &c, sizeof c));
  assert((uintptr_t)args == pointer); va_end(args);
}
int main(void) {
  assert(sizeof(void*) == 4);
  const struct three a = {{1, 17, 255}};
  const struct seven b = {{2, 3, 5, 7, 11, 13, 19}};
  const struct large c = {-123, 456, -789};
  mixed(9, -7, 3.5, 42); aggregates(9, a, b, c);
  puts("GNU PA32 descending va_list: mixed scalars, copied cursor, partial and indirect aggregates passed");
  return 0;
}
