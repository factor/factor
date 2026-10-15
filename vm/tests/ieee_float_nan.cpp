#include "../ieee_binary64.hpp"
#include <stdio.h>
#include <stdlib.h>
#include <initializer_list>
using namespace factor;
int main() {
  software_fp_set_state(0);
  unsigned long count = 0;
  for (uint32_t sign : {UINT32_C(0), UINT32_C(0x80000000)})
    for (uint32_t payload = 1; payload <= UINT32_C(0x007fffff); ++payload) {
      uint32_t bits = sign | UINT32_C(0x7f800000) | payload;
      uint64_t widened = (uint64_t(sign) << 32) | UINT64_C(0x7ff0000000000000) | (uint64_t(payload) << 29);
      auto stored = ieee_binary64::from_float_bits(bits);
      auto numeric = fp::convert<fp::binary64>(fp::binary32{bits}, fp::rounding_mode::nearest_even);
      bool signaling = !(payload & UINT32_C(0x00400000));
      if (stored.bits() != widened || stored.float_bits() != bits || software_fp_flags != 0 ||
          numeric.value.bits != (widened | UINT64_C(0x0008000000000000)) ||
          numeric.raised != (signaling ? fp::invalid : 0)) {
        fprintf(stderr, "binary32 NaN transfer failed: %08x\n", bits); return 1;
      }
      ++count;
    }
  printf("%lu binary32 NaN representation/numerical transfers passed\n", count);
}
