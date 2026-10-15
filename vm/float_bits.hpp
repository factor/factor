#include "ieee_bits.hpp"

namespace factor {

// Factor's stored bits use IEEE's quiet bit. PA-RISC and classic SuperH use the inverse bit
// convention at native arithmetic and foreign-call boundaries. Raw bit APIs
// never apply this conversion. A zero payload after conversion must stay a
// NaN: use a quiet native payload on export and a signaling IEEE payload on
// import. This necessarily remaps those two foreign payload encodings.
template <typename UInt>
inline static UInt inverse_nan_bits(UInt bits, UInt exponent, UInt fraction,
                                 UInt quiet_bit, UInt empty_payload) {
  if ((bits & exponent) == exponent && (bits & fraction) != 0) {
    bits ^= quiet_bit;
    if ((bits & fraction) == 0)
      bits |= empty_payload;
  }
  return bits;
}

inline static uint64_t inverse_native_double_bits(uint64_t bits) {
  return inverse_nan_bits(bits, UINT64_C(0x7ff0000000000000),
                       UINT64_C(0x000fffffffffffff),
                       UINT64_C(0x0008000000000000),
                       UINT64_C(0x0004000000000000));
}

inline static uint64_t inverse_canonical_double_bits(uint64_t bits) {
  return inverse_nan_bits(bits, UINT64_C(0x7ff0000000000000),
                       UINT64_C(0x000fffffffffffff),
                       UINT64_C(0x0008000000000000), UINT64_C(1));
}

inline static uint32_t inverse_native_float_bits(uint32_t bits) {
  return inverse_nan_bits(bits, UINT32_C(0x7f800000), UINT32_C(0x007fffff),
                       UINT32_C(0x00400000), UINT32_C(0x00200000));
}

inline static uint32_t inverse_canonical_float_bits(uint32_t bits) {
  return inverse_nan_bits(bits, UINT32_C(0x7f800000), UINT32_C(0x007fffff),
                       UINT32_C(0x00400000), UINT32_C(1));
}

// Keep existing native fixture entry points source-compatible.
inline static uint64_t hppa_native_double_bits(uint64_t bits) {
  return inverse_native_double_bits(bits);
}
inline static uint64_t hppa_canonical_double_bits(uint64_t bits) {
  return inverse_canonical_double_bits(bits);
}
inline static uint32_t hppa_native_float_bits(uint32_t bits) {
  return inverse_native_float_bits(bits);
}
inline static uint32_t hppa_canonical_float_bits(uint32_t bits) {
  return inverse_canonical_float_bits(bits);
}

// Some functions for converting floating point numbers to binary
// representations and vice versa

union double_bits_pun {
  double x;
  uint64_t y;
};

inline static uint64_t double_bits(double x) {
  double_bits_pun b;
  b.x = x;
  return b.y;
}

inline static double bits_double(uint64_t y) {
  double_bits_pun b;
  b.y = y;
  return b.x;
}

union float_bits_pun {
  float x;
  uint32_t y;
};

inline static uint32_t float_bits(float x) {
  float_bits_pun b;
  b.x = x;
  return b.y;
}

inline static float bits_float(uint32_t y) {
  float_bits_pun b;
  b.y = y;
  return b.x;
}

// NaN encodings are data here. Hardware precision conversions quiet signaling
// NaNs, so move their sign and payload without floating-point arithmetic.
inline static uint64_t widen_float_bits(uint32_t bits) {
#if defined(FACTOR_INTEGER_ONLY)
  return widen_ieee_bits(bits);
#elif defined(__vax__)
  return ieee_binary64::from_float_bits(bits).bits();
#else
  uint32_t payload = bits & 0x007fffffU;
  if ((bits & 0x7f800000U) == 0x7f800000U && payload != 0)
    return ((uint64_t)(bits & 0x80000000U) << 32) |
           0x7ff0000000000000ULL | ((uint64_t)payload << 29);
  return double_bits((double)bits_float(bits));
#endif
}

inline static uint32_t narrow_float_bits(uint64_t bits) {
#if defined(FACTOR_INTEGER_ONLY)
  return narrow_ieee_bits(bits);
#elif defined(__vax__)
  return ieee_binary64::from_bits(bits).float_bits();
#else
  uint64_t payload = bits & 0x000fffffffffffffULL;
  if ((bits & 0x7ff0000000000000ULL) == 0x7ff0000000000000ULL && payload != 0) {
    uint32_t narrowed = (uint32_t)(payload >> 29);
    // A payload entirely below binary32 precision must remain a NaN.
    return (uint32_t)((bits >> 32) & 0x80000000U) | 0x7f800000U |
           (narrowed == 0 ? 1 : narrowed);
  }
  return float_bits((float)bits_double(bits));
#endif
}

}
