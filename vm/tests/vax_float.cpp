#include "../vax_float.hpp"
#include <assert.h>
#include <stdio.h>
#include <string.h>

using factor::vax_float_conversion;

int main() {
  const unsigned char one[] = {0x80, 0x40, 0, 0, 0, 0, 0, 0};
  const unsigned char mixed_call[] = {0x70, 0x41, 0, 0, 0, 0, 0, 0};
  uint64_t ieee;
  assert(factor::vax_d_to_ieee(one, ieee) == vax_float_conversion::exact);
  assert(ieee == UINT64_C(0x3ff0000000000000));
  assert(factor::vax_d_to_ieee(mixed_call, ieee) == vax_float_conversion::exact);
  assert(ieee == UINT64_C(0x400e000000000000));
  unsigned char native[8];
  assert(factor::ieee_to_vax_d(ieee, native) == vax_float_conversion::exact);
  assert(memcmp(native, mixed_call, 8) == 0);
  ieee |= UINT64_C(0x8000000000000000);
  assert(factor::ieee_to_vax_d(ieee, native) == vax_float_conversion::exact);
  assert(native[1] == 0xc1);
  uint64_t negative;
  assert(factor::vax_d_to_ieee(native, negative) == vax_float_conversion::exact);
  assert(negative == ieee);

  // The three excess D-floating fraction bits round to nearest, ties to even.
  memcpy(native, one, 8);
  native[6] = 4;
  assert(factor::vax_d_to_ieee(native, ieee) == vax_float_conversion::rounded);
  assert(ieee == UINT64_C(0x3ff0000000000000));
  native[6] = 12;
  assert(factor::vax_d_to_ieee(native, ieee) == vax_float_conversion::rounded);
  assert(ieee == UINT64_C(0x3ff0000000000002));
  memset(native, 0xff, 8);
  native[0] = 0xff;
  native[1] = 0x40;
  assert(factor::vax_d_to_ieee(native, ieee) == vax_float_conversion::rounded);
  assert(ieee == UINT64_C(0x4000000000000000));

  // Failed conversions cannot inject a reserved operand into a native call.
  memset(native, 0, 8);
  native[1] = 0x80;
  ieee = 123;
  assert(factor::vax_d_to_ieee(native, ieee) == vax_float_conversion::reserved_operand);
  assert(ieee == 123);
  memset(native, 0xa5, 8);
  assert(factor::ieee_to_vax_d(UINT64_C(0x7ff0000000000000), native) ==
         vax_float_conversion::nonfinite);
  assert(factor::ieee_to_vax_d(UINT64_C(0x7ff8000000000001), native) ==
         vax_float_conversion::nonfinite);
  assert(factor::ieee_to_vax_d(UINT64_C(1), native) == vax_float_conversion::underflow);
  assert(factor::ieee_to_vax_d(UINT64_C(0x7fefffffffffffff), native) ==
         vax_float_conversion::overflow);
  for (unsigned i = 0; i < 8; ++i) assert(native[i] == 0xa5);
  assert(factor::ieee_to_vax_d(UINT64_C(0x8000000000000000), native) ==
         vax_float_conversion::rounded);
  for (unsigned i = 0; i < 8; ++i) assert(native[i] == 0);
  native[6] = 1;
  assert(factor::vax_d_to_ieee(native, ieee) == vax_float_conversion::dirty_zero);
  assert(ieee == 0);

  uint32_t ieee32;
  assert(factor::vax_f_to_ieee(one, ieee32) == vax_float_conversion::exact);
  assert(ieee32 == UINT32_C(0x3f800000));
  assert(factor::ieee_to_vax_f(ieee32, native) == vax_float_conversion::exact);
  assert(memcmp(one, native, 4) == 0);
  // F-floating's two lowest exponents use IEEE binary32 subnormal encodings.
  const uint32_t subnormal[] = {UINT32_C(0x00200000), UINT32_C(0x00400000),
                               UINT32_C(0x007fffff)};
  for (unsigned i = 0; i < 3; ++i) {
    assert(factor::ieee_to_vax_f(subnormal[i], native) == vax_float_conversion::exact);
    assert(factor::vax_f_to_ieee(native, ieee32) == vax_float_conversion::exact);
    assert(ieee32 == subnormal[i]);
  }
  memset(native, 0, 4);
  native[0] = 0x80; // F exponent 1, fraction 0.
  native[2] = 2; // Halfway between adjacent IEEE subnormals, even rounds down.
  assert(factor::vax_f_to_ieee(native, ieee32) == vax_float_conversion::rounded);
  assert(ieee32 == UINT32_C(0x00200000));
  native[2] = 6;
  assert(factor::vax_f_to_ieee(native, ieee32) == vax_float_conversion::rounded);
  assert(ieee32 == UINT32_C(0x00200002));
  memset(native, 0xa5, 4);
  assert(factor::ieee_to_vax_f(UINT32_C(0x7f800001), native) ==
         vax_float_conversion::nonfinite);
  assert(factor::ieee_to_vax_f(UINT32_C(0x7f000000), native) ==
         vax_float_conversion::overflow);
  assert(factor::ieee_to_vax_f(UINT32_C(0x001fffff), native) ==
         vax_float_conversion::underflow);
  for (unsigned i = 0; i < 4; ++i) assert(native[i] == 0xa5);

#if defined(__vax__) && !defined(__GFLOAT__)
  // Compare against the actual default C++ ABI, never a host IEEE double.
  const double value = 3.75;
  assert(memcmp(&value, mixed_call, 8) == 0);
  assert(factor::vax_d_to_ieee(&value, ieee) == vax_float_conversion::exact);
  assert(ieee == UINT64_C(0x400e000000000000));
  assert(factor::ieee_to_vax_d(ieee, native) == vax_float_conversion::exact);
  double restored;
  memcpy(&restored, native, 8);
  assert(restored == value);
  double power = 1.0;
  for (unsigned exponent = 1023; exponent <= 1149; ++exponent) {
    assert(factor::vax_d_to_ieee(&power, ieee) == vax_float_conversion::exact);
    assert(ieee == ((uint64_t)exponent << 52));
    assert(factor::ieee_to_vax_d(ieee, native) == vax_float_conversion::exact);
    assert(memcmp(&power, native, 8) == 0);
    if (exponent != 1149) power *= 2.0;
  }
  power = 1.0;
  for (unsigned step = 1; step <= 128; ++step) {
    power /= 2.0;
    assert(factor::vax_d_to_ieee(&power, ieee) == vax_float_conversion::exact);
    assert(ieee == ((uint64_t)(1023 - step) << 52));
    assert(factor::ieee_to_vax_d(ieee, native) == vax_float_conversion::exact);
    assert(memcmp(&power, native, 8) == 0);
  }
  float float_power = 1.0f;
  for (unsigned exponent = 127; exponent <= 253; ++exponent) {
    assert(factor::vax_f_to_ieee(&float_power, ieee32) == vax_float_conversion::exact);
    assert(ieee32 == (exponent << 23));
    assert(factor::ieee_to_vax_f(ieee32, native) == vax_float_conversion::exact);
    assert(memcmp(&float_power, native, 4) == 0);
    if (exponent != 253) float_power *= 2.0f;
  }
  float_power = 1.0f;
  for (unsigned step = 1; step <= 128; ++step) {
    float_power /= 2.0f;
    uint32_t expected = step <= 126 ? ((127 - step) << 23)
                                  : (UINT32_C(0x00400000) >> (step - 127));
    assert(factor::vax_f_to_ieee(&float_power, ieee32) == vax_float_conversion::exact);
    assert(ieee32 == expected);
    assert(factor::ieee_to_vax_f(ieee32, native) == vax_float_conversion::exact);
    assert(memcmp(&float_power, native, 4) == 0);
  }
#endif
  puts("vax F/D-floating/IEEE conversion passed");
}
