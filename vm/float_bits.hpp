namespace factor {

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
  uint32_t payload = bits & 0x007fffffU;
  if ((bits & 0x7f800000U) == 0x7f800000U && payload != 0)
    return ((uint64_t)(bits & 0x80000000U) << 32) |
           0x7ff0000000000000ULL | ((uint64_t)payload << 29);
  return double_bits((double)bits_float(bits));
}

inline static uint32_t narrow_float_bits(uint64_t bits) {
  uint64_t payload = bits & 0x000fffffffffffffULL;
  if ((bits & 0x7ff0000000000000ULL) == 0x7ff0000000000000ULL && payload != 0) {
    uint32_t narrowed = (uint32_t)(payload >> 29);
    // A payload entirely below binary32 precision must remain a NaN.
    return (uint32_t)((bits >> 32) & 0x80000000U) | 0x7f800000U |
           (narrowed == 0 ? 1 : narrowed);
  }
  return float_bits((float)bits_double(bits));
}

}
