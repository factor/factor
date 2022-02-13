namespace factor {

inline static uint64_t double_bits(double x) {
  return *(reinterpret_cast<uint64_t*>(&x));
}

inline static double bits_double(uint64_t y) {
  return *(reinterpret_cast<double*>(&y));
}

inline static uint32_t float_bits(float x) {
  return *(reinterpret_cast<uint32_t*>(&x));
}

inline static float bits_float(uint32_t y) {
  return *(reinterpret_cast<float*>(&y));
}

}
