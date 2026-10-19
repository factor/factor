#include <assert.h>
#include <stdio.h>
#include "../ieee_bits.hpp"
int main() {
  using namespace factor;
  // Signed zero, infinities, subnormal boundaries, and signaling NaN payloads.
  const uint32_t singles[] = {0, 0x80000000, 1, 0x007fffff, 0x00800000,
    0x3f800000, 0x7f7fffff, 0x7f800000, 0xff800000, 0x7f800001, 0x7fc12345};
  for (uint32_t bits : singles)
    assert(narrow_ieee_bits(widen_ieee_bits(bits)) == bits);
  assert(widen_ieee_bits(1) == UINT64_C(0x36a0000000000000));
  assert(narrow_ieee_bits(UINT64_C(0x3ff0000010000000)) == 0x3f800000);
  assert(narrow_ieee_bits(UINT64_C(0x3ff0000030000000)) == 0x3f800002);
  assert(narrow_ieee_bits(UINT64_C(0x3690000000000000)) == 0);
  assert(narrow_ieee_bits(UINT64_C(0x3690000000000001)) == 1);
  assert(narrow_ieee_bits(UINT64_C(0x7ff0000000000001)) == 0x7f800001);
  uint32_t random = 1234567;
  for (unsigned i = 0; i != 1000000; ++i) {
    random ^= random << 13; random ^= random >> 17; random ^= random << 5;
    assert(narrow_ieee_bits(widen_ieee_bits(random)) == random);
  }
  puts("integer IEEE bit conversion boundaries and 1,000,000 round trips passed");
}
