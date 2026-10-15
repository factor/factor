#ifndef FACTOR_IEEE_BITS_HPP
#define FACTOR_IEEE_BITS_HPP
#include <stdint.h>
namespace factor {
// Representation-only conversion, independent of native FP instructions/state.
inline uint64_t widen_ieee_bits(uint32_t bits) {
  uint64_t sign = (uint64_t)(bits & UINT32_C(0x80000000)) << 32;
  unsigned exponent = (bits >> 23) & 255;
  uint64_t fraction = bits & UINT32_C(0x007fffff);
  if (exponent == 255)
    return sign | UINT64_C(0x7ff0000000000000) | (fraction << 29);
  if (!exponent) {
    if (!fraction) return sign;
    int power = -126;
    while (!(fraction & UINT64_C(0x00800000))) { fraction <<= 1; --power; }
    return sign | ((uint64_t)(power + 1023) << 52) |
           ((fraction & UINT64_C(0x007fffff)) << 29);
  }
  return sign | ((uint64_t)(exponent + 896) << 52) | (fraction << 29);
}
inline uint64_t round_ieee_bits(uint64_t value, unsigned shift) {
  if (shift >= 64) return 0;
  if (!shift) return value;
  uint64_t quotient = value >> shift;
  uint64_t remainder = value & ((UINT64_C(1) << shift) - 1);
  uint64_t half = UINT64_C(1) << (shift - 1);
  return quotient + (remainder > half || (remainder == half && (quotient & 1)));
}
// Integer-only mode has no FP rounding environment: use nearest, ties to even.
inline uint32_t narrow_ieee_bits(uint64_t bits) {
  uint32_t sign = (uint32_t)(bits >> 32) & UINT32_C(0x80000000);
  unsigned exponent = (unsigned)((bits >> 52) & 2047);
  uint64_t fraction = bits & UINT64_C(0x000fffffffffffff);
  if (exponent == 2047) {
    uint32_t payload = (uint32_t)(fraction >> 29);
    return sign | UINT32_C(0x7f800000) | (fraction && !payload ? 1 : payload);
  }
  if (!exponent) return sign;
  int power = (int)exponent - 1023;
  uint64_t significand = fraction | UINT64_C(0x0010000000000000);
  if (power < -126) {
    unsigned shift = (unsigned)(-power - 97);
    return sign | (uint32_t)round_ieee_bits(significand, shift);
  }
  if (power > 127) return sign | UINT32_C(0x7f800000);
  uint64_t rounded = round_ieee_bits(significand, 29);
  if (rounded == UINT64_C(0x01000000)) { rounded >>= 1; ++power; }
  if (power > 127) return sign | UINT32_C(0x7f800000);
  return sign | ((uint32_t)(power + 127) << 23) |
         ((uint32_t)rounded & UINT32_C(0x007fffff));
}
}
#endif
