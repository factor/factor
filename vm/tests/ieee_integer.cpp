#include "../ieee_integer.hpp"
#include <assert.h>
#include <stdio.h>
#include <initializer_list>

int main() {
  const uint64_t three = UINT64_C(0x400e000000000000); // 3.75 truncates to 3.
  assert(factor::ieee_integer_length(three, 30) == 1);
  assert(factor::ieee_integer_digit(three, 30, 0) == 3);
  assert(factor::ieee_integer_length(UINT64_C(1), 30) == 0);
  assert(factor::ieee_integer_length(UINT64_C(0x7ff0000000000000), 30) == 0);
  assert(factor::ieee_integer_length(UINT64_C(0x7ff0000000000001), 30) == 0);
  for (unsigned digit_bits : {30U, 62U}) {
    for (unsigned power = 0; power <= 1023; ++power) {
      uint64_t bits = (uint64_t)(power + 1023) << 52;
      unsigned length = factor::ieee_integer_length(bits, digit_bits);
      assert(length == power / digit_bits + 1);
      for (unsigned i = 0; i < length; ++i)
        assert(factor::ieee_integer_digit(bits, digit_bits, i) ==
               (i == power / digit_bits ? UINT64_C(1) << (power % digit_bits) : 0));
    }
    uint64_t largest = UINT64_C(0x7fefffffffffffff);
    unsigned length = factor::ieee_integer_length(largest, digit_bits);
    unsigned highest = 1023 % digit_bits;
    assert(factor::ieee_integer_digit(largest, digit_bits, length - 1) ==
           (((UINT64_C(1) << (highest + 1)) - 1) &
            ~((UINT64_C(1) << (highest > 52 ? highest - 52 : 0)) - 1)));
  }
  puts("IEEE binary64 integer magnitude extraction passed");
}
