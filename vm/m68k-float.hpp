#pragma once

// Integer rounding for the 68881 double-precision/subnormal double-rounding
// boundary. No software floating-point state is read or modified.
#include <cstdint>
#include <cstring>

namespace factor {
namespace m68k_float {
struct wide { uint64_t high, low; };

inline wide multiply(uint64_t a, uint64_t b) {
  uint64_t low = uint64_t(uint32_t(a)) * uint32_t(b);
  uint64_t cross1 = (a >> 32) * uint32_t(b);
  uint64_t cross2 = uint32_t(a) * (b >> 32);
  uint64_t middle = (low >> 32) + uint32_t(cross1) + uint32_t(cross2);
  return {(a >> 32) * (b >> 32) + (cross1 >> 32) +
          (cross2 >> 32) + (middle >> 32),
          (middle << 32) | uint32_t(low)};
}

inline uint64_t round_shift(wide value, unsigned shift) {
  if (shift >= 128)
    return 0; // Products have at most 106 significant bits.
  uint64_t quotient;
  bool half, sticky;
  if (shift > 64) {
    unsigned high_shift = shift - 64;
    quotient = value.high >> high_shift;
    half = (value.high >> (high_shift - 1)) & 1;
    sticky = value.low || (value.high & ((uint64_t(1) << (high_shift - 1)) - 1));
  } else {
    quotient = shift == 64 ? value.high :
      (value.high << (64 - shift)) | (value.low >> shift);
    half = (value.low >> (shift - 1)) & 1;
    sticky = value.low & ((uint64_t(1) << (shift - 1)) - 1);
  }
  return quotient + (half && (sticky || (quotient & 1)));
}

inline uint64_t round_divide(wide numerator, uint64_t denominator) {
  uint64_t remainder = 0, quotient = 0;
  for (int bit = 127; bit >= 0; --bit) {
    remainder = (remainder << 1) |
      ((bit >= 64 ? numerator.high >> (bit - 64) : numerator.low >> bit) & 1);
    quotient <<= 1;
    if (remainder >= denominator) {
      remainder -= denominator;
      quotient |= 1;
    }
  }
  uint64_t twice = remainder << 1;
  return quotient + (twice > denominator ||
                     (twice == denominator && (quotient & 1)));
}

inline double correct_underflow(double result, double x, double y, bool division) {
  uint64_t bits, a, b;
  memcpy(&bits, &result, 8);
  if ((bits & 0x7fffffffffffffffULL) > 0x0010000000000000ULL)
    return result;
  uint32_t control;
  asm volatile("fmove.l %%fpcr,%0" : "=d"(control) : : "memory");
  if (control & 0x30)
    return result;
  memcpy(&a, &x, 8);
  memcpy(&b, &y, 8);
  uint64_t sign = (a ^ b) & 0x8000000000000000ULL;
  int exponent_a = (a >> 52) & 0x7ff, exponent_b = (b >> 52) & 0x7ff;
  if (exponent_a == 0x7ff || exponent_b == 0x7ff)
    return result;
  uint64_t significand_a = (a & 0x000fffffffffffffULL) |
    (exponent_a ? uint64_t(1) << 52 : 0);
  uint64_t significand_b = (b & 0x000fffffffffffffULL) |
    (exponent_b ? uint64_t(1) << 52 : 0);
  exponent_a = exponent_a ? exponent_a - 1023 : -1022;
  exponent_b = exponent_b ? exponent_b - 1023 : -1022;
  uint64_t rounded = 0;
  if (significand_a && significand_b) {
    if (division) {
      int shift = exponent_a - exponent_b + 1074;
      if (shift >= 0) {
        // A result at most DBL_MIN bounds this numerator to 106 bits.
        wide numerator = shift >= 64 ? wide{significand_a << (shift - 64), 0} :
          (shift ? wide{significand_a >> (64 - shift), significand_a << shift} :
                   wide{0, significand_a});
        rounded = round_divide(numerator, significand_b);
      } else if (-shift < 64 && significand_b <= (UINT64_MAX >> -shift)) {
        rounded = round_divide({0, significand_a}, significand_b << -shift);
      }
    } else {
      int shift = -(exponent_a + exponent_b + 970);
      rounded = round_shift(multiply(significand_a, significand_b), unsigned(shift));
    }
  }
  bits = sign | rounded;
  memcpy(&result, &bits, 8);
  return result;
}
} // namespace m68k_float
} // namespace factor
