#include "../vax_float.hpp"
#include <assert.h>
#include <stdio.h>
#include <string.h>

using factor::vax_float_conversion;

int main() {
  const unsigned char one[] = {0x10, 0x40, 0, 0, 0, 0, 0, 0};
  const unsigned char mixed[] = {0x2e, 0x40, 0, 0, 0, 0, 0, 0};
  uint64_t ieee;
  unsigned char native[8];
  assert(factor::vax_g_to_ieee(one, ieee) == vax_float_conversion::exact);
  assert(ieee == UINT64_C(0x3ff0000000000000));
  assert(factor::vax_g_to_ieee(mixed, ieee) == vax_float_conversion::exact);
  assert(ieee == UINT64_C(0x400e000000000000));
  assert(factor::ieee_to_vax_g(ieee, native) == vax_float_conversion::exact);
  assert(memcmp(native, mixed, 8) == 0);
  const uint64_t subnormal[] = {UINT64_C(0x0004000000000000),
                               UINT64_C(0x0008000000000000),
                               UINT64_C(0x000fffffffffffff)};
  for (unsigned i = 0; i < 3; ++i) {
    assert(factor::ieee_to_vax_g(subnormal[i], native) == vax_float_conversion::exact);
    assert(factor::vax_g_to_ieee(native, ieee) == vax_float_conversion::exact);
    assert(ieee == subnormal[i]);
  }
  memset(native, 0, 8);
  native[0] = 0x10;
  native[6] = 2;
  assert(factor::vax_g_to_ieee(native, ieee) == vax_float_conversion::rounded);
  assert(ieee == subnormal[0]);
  native[6] = 6;
  assert(factor::vax_g_to_ieee(native, ieee) == vax_float_conversion::rounded);
  assert(ieee == subnormal[0] + 2);
  native[1] = 0x80;
  native[0] = 0;
  ieee = 123;
  assert(factor::vax_g_to_ieee(native, ieee) == vax_float_conversion::reserved_operand);
  assert(ieee == 123);
  native[1] = 0;
  assert(factor::vax_g_to_ieee(native, ieee) == vax_float_conversion::dirty_zero);
  assert(ieee == 0);
  memset(native, 0xa5, 8);
  assert(factor::ieee_to_vax_g(UINT64_C(0x7ff0000000000000), native) ==
         vax_float_conversion::nonfinite);
  assert(factor::ieee_to_vax_g(UINT64_C(0x7ff8000000000001), native) ==
         vax_float_conversion::nonfinite);
  assert(factor::ieee_to_vax_g(UINT64_C(0x7fe0000000000000), native) ==
         vax_float_conversion::overflow);
  assert(factor::ieee_to_vax_g(subnormal[0] - 1, native) ==
         vax_float_conversion::underflow);
  for (unsigned i = 0; i < 8; ++i) assert(native[i] == 0xa5);
  assert(factor::ieee_to_vax_g(UINT64_C(0x8000000000000000), native) ==
         vax_float_conversion::rounded);
  for (unsigned i = 0; i < 8; ++i) assert(native[i] == 0);
#if defined(__vax__) && defined(__GFLOAT__)
  const double value = 3.75;
  assert(memcmp(&value, mixed, 8) == 0);
  double power = 1.0;
  for (unsigned exponent = 1023; exponent <= 2045; ++exponent) {
    assert(factor::vax_g_to_ieee(&power, ieee) == vax_float_conversion::exact);
    assert(ieee == ((uint64_t)exponent << 52));
    assert(factor::ieee_to_vax_g(ieee, native) == vax_float_conversion::exact);
    assert(memcmp(&power, native, 8) == 0);
    if (exponent != 2045) power *= 2.0;
  }
  power = 1.0;
  for (unsigned step = 0; step <= 1024; ++step) {
    assert(factor::vax_g_to_ieee(&power, ieee) == vax_float_conversion::exact);
    uint64_t expected = step <= 1022 ? (uint64_t)(1023 - step) << 52
                                   : UINT64_C(0x0010000000000000) >> (step - 1022);
    assert(ieee == expected);
    assert(factor::ieee_to_vax_g(ieee, native) == vax_float_conversion::exact);
    assert(memcmp(&power, native, 8) == 0);
    if (step != 1024) power *= 0.5;
  }
#endif
  puts("vax G-floating/IEEE conversion passed");
}
