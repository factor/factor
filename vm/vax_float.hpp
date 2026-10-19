#ifndef FACTOR_VAX_FLOAT_HPP
#define FACTOR_VAX_FLOAT_HPP

#include <stdint.h>

namespace factor {

enum class vax_float_conversion {
  exact, rounded, dirty_zero, reserved_operand, underflow, overflow, nonfinite
};

inline uint16_t vax_float_word(const unsigned char* bytes) {
  return (uint16_t)bytes[0] | ((uint16_t)bytes[1] << 8);
}

inline void vax_float_store_word(unsigned char* bytes, uint16_t word) {
  bytes[0] = (unsigned char)word;
  bytes[1] = (unsigned char)(word >> 8);
}

inline vax_float_conversion vax_f_to_ieee(const void* native, uint32_t& ieee) {
  const unsigned char* bytes = (const unsigned char*)native;
  uint16_t first = vax_float_word(bytes);
  unsigned exponent = (first >> 7) & 0xff;
  uint32_t fraction = ((uint32_t)(first & 0x7f) << 16) |
                      vax_float_word(bytes + 2);
  if (exponent == 0) {
    if (first & 0x8000)
      return vax_float_conversion::reserved_operand;
    ieee = 0;
    return fraction == 0 ? vax_float_conversion::exact
                         : vax_float_conversion::dirty_zero;
  }
  uint32_t sign = (uint32_t)(first & 0x8000) << 16;
  if (exponent >= 3) {
    ieee = sign | ((exponent - 2) << 23) | fraction;
    return vax_float_conversion::exact;
  }
  // The bottom two F-floating exponents become IEEE subnormals.
  unsigned shift = 3 - exponent;
  uint32_t significand = fraction | UINT32_C(0x00800000);
  uint32_t rounded = significand >> shift;
  unsigned remainder = significand & ((1U << shift) - 1);
  unsigned halfway = 1U << (shift - 1);
  if (remainder > halfway || (remainder == halfway && (rounded & 1)))
    ++rounded;
  ieee = sign | rounded;
  return remainder == 0 ? vax_float_conversion::exact
                         : vax_float_conversion::rounded;
}

inline vax_float_conversion ieee_to_vax_f(uint32_t ieee, void* native) {
  unsigned exponent = (ieee >> 23) & 0xff;
  uint32_t fraction = ieee & UINT32_C(0x007fffff);
  uint16_t first = 0;
  vax_float_conversion result = vax_float_conversion::exact;
  if (exponent == 0 && fraction == 0) {
    if (ieee >> 31)
      result = vax_float_conversion::rounded;
  } else {
    if (exponent == 0xff)
      return vax_float_conversion::nonfinite;
    if (exponent == 0xfe)
      return vax_float_conversion::overflow;
    if (exponent == 0) {
      if (fraction < UINT32_C(0x00200000))
        return vax_float_conversion::underflow;
      unsigned shift = fraction < UINT32_C(0x00400000) ? 2 : 1;
      exponent = 3 - shift;
      fraction = (fraction << shift) & UINT32_C(0x007fffff);
    } else {
      exponent += 2;
    }
    first = (uint16_t)(((ieee >> 16) & 0x8000) |
                       (exponent << 7) | (fraction >> 16));
  }
  unsigned char* bytes = (unsigned char*)native;
  vax_float_store_word(bytes, first);
  vax_float_store_word(bytes + 2, (uint16_t)fraction);
  return result;
}

// NetBSD/vax's default native double is D-floating: four little-endian words,
// with the exponent/sign in the first word and 55 fraction bits following.
// Keep native reserved operands out of the host floating-point unit.
inline vax_float_conversion vax_d_to_ieee(const void* native, uint64_t& ieee) {
  const unsigned char* bytes = (const unsigned char*)native;
  uint16_t first = vax_float_word(bytes);
  unsigned exponent = (first >> 7) & 0xff;
  uint64_t fraction = ((uint64_t)(first & 0x7f) << 48) |
                      ((uint64_t)vax_float_word(bytes + 2) << 32) |
                      ((uint64_t)vax_float_word(bytes + 4) << 16) |
                      vax_float_word(bytes + 6);
  if (exponent == 0) {
    if (first & 0x8000)
      return vax_float_conversion::reserved_operand;
    ieee = 0;
    return fraction == 0 ? vax_float_conversion::exact
                         : vax_float_conversion::dirty_zero;
  }
  uint64_t rounded = fraction >> 3;
  unsigned remainder = fraction & 7;
  if (remainder > 4 || (remainder == 4 && (rounded & 1)))
    ++rounded;
  unsigned ieee_exponent = exponent + 894;
  if (rounded == UINT64_C(0x0010000000000000)) {
    rounded = 0;
    ++ieee_exponent;
  }
  ieee = ((uint64_t)(first & 0x8000) << 48) |
         ((uint64_t)ieee_exponent << 52) | rounded;
  return remainder == 0 ? vax_float_conversion::exact
                         : vax_float_conversion::rounded;
}

// An unrepresentable input leaves the destination untouched. In particular,
// an IEEE NaN/infinity must never become a native reserved operand implicitly.
inline vax_float_conversion ieee_to_vax_d(uint64_t ieee, void* native) {
  unsigned exponent = (unsigned)((ieee >> 52) & 0x7ff);
  uint64_t fraction = ieee & UINT64_C(0x000fffffffffffff);
  uint16_t first;
  vax_float_conversion result = vax_float_conversion::exact;
  if (exponent == 0 && fraction == 0) {
    first = 0;
    if (ieee >> 63)
      result = vax_float_conversion::rounded;
  } else {
    if (exponent == 0x7ff)
      return vax_float_conversion::nonfinite;
    if (exponent < 895)
      return vax_float_conversion::underflow;
    if (exponent > 1149)
      return vax_float_conversion::overflow;
    first = (uint16_t)(((ieee >> 48) & 0x8000) |
                       ((exponent - 894) << 7) | (fraction >> 45));
    fraction <<= 3;
  }
  unsigned char* bytes = (unsigned char*)native;
  vax_float_store_word(bytes, first);
  vax_float_store_word(bytes + 2, (uint16_t)(fraction >> 32));
  vax_float_store_word(bytes + 4, (uint16_t)(fraction >> 16));
  vax_float_store_word(bytes + 6, (uint16_t)fraction);
  return result;
}

// GCC -mg selects G-floating, not IEEE: its exponent is biased two higher,
// and its 16-bit words retain the VAX ordering.
inline vax_float_conversion vax_g_to_ieee(const void* native, uint64_t& ieee) {
  const unsigned char* bytes = (const unsigned char*)native;
  uint16_t first = vax_float_word(bytes);
  unsigned exponent = (first >> 4) & 0x7ff;
  uint64_t fraction = ((uint64_t)(first & 0xf) << 48) |
                      ((uint64_t)vax_float_word(bytes + 2) << 32) |
                      ((uint64_t)vax_float_word(bytes + 4) << 16) |
                      vax_float_word(bytes + 6);
  if (exponent == 0) {
    if (first & 0x8000)
      return vax_float_conversion::reserved_operand;
    ieee = 0;
    return fraction == 0 ? vax_float_conversion::exact
                         : vax_float_conversion::dirty_zero;
  }
  uint64_t sign = (uint64_t)(first & 0x8000) << 48;
  if (exponent >= 3) {
    ieee = sign | ((uint64_t)(exponent - 2) << 52) | fraction;
    return vax_float_conversion::exact;
  }
  unsigned shift = 3 - exponent;
  uint64_t significand = fraction | UINT64_C(0x0010000000000000);
  uint64_t rounded = significand >> shift;
  unsigned remainder = (unsigned)(significand & ((1U << shift) - 1));
  unsigned halfway = 1U << (shift - 1);
  if (remainder > halfway || (remainder == halfway && (rounded & 1)))
    ++rounded;
  ieee = sign | rounded;
  return remainder == 0 ? vax_float_conversion::exact
                         : vax_float_conversion::rounded;
}

inline vax_float_conversion ieee_to_vax_g(uint64_t ieee, void* native) {
  unsigned exponent = (unsigned)((ieee >> 52) & 0x7ff);
  uint64_t fraction = ieee & UINT64_C(0x000fffffffffffff);
  uint16_t first = 0;
  vax_float_conversion result = vax_float_conversion::exact;
  if (exponent == 0 && fraction == 0) {
    if (ieee >> 63)
      result = vax_float_conversion::rounded;
  } else {
    if (exponent == 0x7ff)
      return vax_float_conversion::nonfinite;
    if (exponent == 0x7fe)
      return vax_float_conversion::overflow;
    if (exponent == 0) {
      if (fraction < UINT64_C(0x0004000000000000))
        return vax_float_conversion::underflow;
      unsigned shift = fraction < UINT64_C(0x0008000000000000) ? 2 : 1;
      exponent = 3 - shift;
      fraction = (fraction << shift) & UINT64_C(0x000fffffffffffff);
    } else {
      exponent += 2;
    }
    first = (uint16_t)(((ieee >> 48) & 0x8000) |
                       (exponent << 4) | (fraction >> 48));
  }
  unsigned char* bytes = (unsigned char*)native;
  vax_float_store_word(bytes, first);
  vax_float_store_word(bytes + 2, (uint16_t)(fraction >> 32));
  vax_float_store_word(bytes + 4, (uint16_t)(fraction >> 16));
  vax_float_store_word(bytes + 6, (uint16_t)fraction);
  return result;
}

}

#endif
