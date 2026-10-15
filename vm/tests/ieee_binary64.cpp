#include "../ieee_binary64.hpp"
#if defined(__vax__)
#include "../vax_float.hpp"
#endif
#include <assert.h>
#include <stdio.h>
#include <string.h>

using factor::ieee_binary64;

int main() {
  ieee_binary64 one = ieee_binary64::from_signed(1);
  ieee_binary64 two = ieee_binary64::from_unsigned(2);
  assert(one.bits() == UINT64_C(0x3ff0000000000000));
  assert((one + one) == two);
  assert((two - one) == one);
  assert((two * two).to_signed() == 4);
  assert((one / two).bits() == UINT64_C(0x3fe0000000000000));
  assert(two.sqrt().bits() == UINT64_C(0x3ff6a09e667f3bcd));
  assert((-one).sign() && (-one).abs() == one);
  assert(one < two && one <= one && two > one && two >= two);
  ieee_binary64 negative_zero = ieee_binary64::from_bits(UINT64_C(0x8000000000000000));
  assert(negative_zero.is_zero() && negative_zero.sign());
  assert(negative_zero == ieee_binary64());
  ieee_binary64 infinity = one / ieee_binary64();
  assert(infinity.bits() == UINT64_C(0x7ff0000000000000));
  assert(infinity.is_infinite() && !infinity.is_finite());
  ieee_binary64 nan = ieee_binary64::from_bits(UINT64_C(0x7ff0000000000001));
  assert(nan.is_nan() && nan.bits() == UINT64_C(0x7ff0000000000001));
  assert(!(nan == nan) && nan != nan);
  ieee_binary64 subnormal = ieee_binary64::from_bits(1);
  assert(subnormal.is_finite() && !subnormal.is_zero());
  assert((subnormal * two).bits() == 2);
  assert(subnormal.sqrt().bits() == UINT64_C(0x1e60000000000000));
  assert(negative_zero.sqrt().bits() == negative_zero.bits());
  assert(infinity.sqrt().bits() == infinity.bits());
  factor::software_fp_set_state(0);
  assert((-one).sqrt().is_nan());
  assert(factor::software_fp_get_state() & factor::fp::invalid);
  factor::software_fp_set_state(0);
  assert(nan.sqrt().is_nan());
  assert(factor::software_fp_get_state() & factor::fp::invalid);
  assert(ieee_binary64::from_float_bits(1).bits() == UINT64_C(0x36a0000000000000));
  assert(ieee_binary64::from_float_bits(1).float_bits() == 1);
  assert(ieee_binary64::from_float_bits(UINT32_C(0x7f800001)).bits() ==
         UINT64_C(0x7ff0000020000000));
  assert(ieee_binary64::from_float_bits(UINT32_C(0xff800001)).float_bits() ==
         UINT32_C(0xff800001));
  assert(nan.float_bits() == UINT32_C(0x7f800001));
  assert(ieee_binary64::from_bits(UINT64_C(0x7ff8000000000001)).float_bits() ==
         UINT32_C(0x7fc00000));
  uint64_t stored;
  memcpy(&stored, &nan, sizeof(stored));
  assert(stored == nan.bits());

#if defined(__vax__)
  const double native = 1.0;
  uint64_t bits;
  assert(factor::vax_d_to_ieee(&native, bits) == factor::vax_float_conversion::exact);
  assert(ieee_binary64::from_bits(bits) == one);
  double restored;
  assert(factor::ieee_to_vax_d(one.bits(), &restored) == factor::vax_float_conversion::exact);
  assert(restored == native);
  assert(memcmp(&one, &native, sizeof(native)) != 0);
#endif
  puts("IEEE binary64 C++ storage/arithmetic passed");
}
