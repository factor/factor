#include "../ieee_float.h"
#include <assert.h>
#include <stdio.h>

int main(void) {
  uint64_t value = 43;
  uint32_t single = 17;
  uint8_t flags = 29, order = 0, valid = 0;
  int64_t integer = 0;
  const uint64_t one = UINT64_C(0x3ff0000000000000), two = UINT64_C(0x4000000000000000);
  assert(factor_fp64_binary(FACTOR_FP_ADD, one, one, FACTOR_FP_NEAREST_EVEN, &value, &flags) == FACTOR_FP_OK);
  assert(value == two && flags == 0);
  assert(factor_fp64_binary(FACTOR_FP_MULTIPLY, two, two, 0, &value, &flags) == 0);
  assert(value == UINT64_C(0x4010000000000000) && flags == 0);
  assert(factor_fp64_binary(FACTOR_FP_DIVIDE, one, two, 0, &value, &flags) == 0);
  assert(value == UINT64_C(0x3fe0000000000000) && flags == 0);
  assert(factor_fp64_sqrt(two, 0, &value, &flags) == 0);
  assert(value == UINT64_C(0x3ff6a09e667f3bcd) && flags == FACTOR_FP_INEXACT);
  assert(factor_fp64_binary(FACTOR_FP_MULTIPLY, 1, two, 0, &value, &flags) == 0 && value == 2 && flags == 0);
  assert(factor_fp64_to_fp32(one, 0, &single, &flags) == 0 && single == UINT32_C(0x3f800000));
  assert(factor_fp32_to_fp64(1, 0, &value, &flags) == 0 && value == UINT64_C(0x36a0000000000000));
  assert(factor_fp64_binary(FACTOR_FP_DIVIDE, one, 0, 0, &value, &flags) == 0);
  assert(value == UINT64_C(0x7ff0000000000000) && flags == FACTOR_FP_DIVIDE_BY_ZERO);
  assert(factor_fp64_to_i64(value, 0, &integer, &valid, &flags) == 0);
  assert(integer == 0 && !valid && flags == FACTOR_FP_INVALID);
  assert(factor_fp64_from_i64(INT64_MIN, 0, &value, &flags) == 0);
  assert(value == UINT64_C(0xc3e0000000000000) && flags == 0);
  assert(factor_fp64_compare(one, two, FACTOR_FP_QUIET, &order, &flags) == 0);
  assert(order == FACTOR_FP_LESS && flags == 0);
  assert(factor_fp32_fma(UINT32_C(0x3f800000), UINT32_C(0x40000000), UINT32_C(0x3f800000), 0, &single, &flags) == 0);
  assert(single == UINT32_C(0x40400000) && flags == 0);
  value = 43; flags = 29;
  assert(factor_fp64_binary(0, one, two, 5, &value, &flags) == FACTOR_FP_BAD_MODE);
  assert(value == 43 && flags == 29);
  assert(factor_fp64_binary(99, one, two, 0, &value, &flags) == FACTOR_FP_BAD_ARGUMENT);
  assert(value == 43 && flags == 29);
  assert(factor_fp64_sqrt(one, 0, 0, &flags) == FACTOR_FP_BAD_ARGUMENT && flags == 29);
  assert(factor_fp64_to_i64(one, 0, &integer, 0, &flags) == FACTOR_FP_BAD_ARGUMENT && flags == 29);
  assert(factor_fp64_compare(one, two, 2, &order, &flags) == FACTOR_FP_BAD_ARGUMENT && flags == 29);
  puts("Factor IEEE C ABI and former VAX arithmetic cases passed");
}
