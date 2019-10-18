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

}
