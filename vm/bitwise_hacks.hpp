#include <bit>

namespace factor {

inline cell log2(cell x) {
  // C++20: Use std::bit_width - 1 for log2
  return std::bit_width(x) - 1;
}

inline cell rightmost_clear_bit(cell x) {
  // Find the rightmost clear bit position
  return std::countr_one(x);
}

inline cell rightmost_set_bit(cell x) {
  // Find the rightmost set bit position
  return std::countr_zero(x);
}

inline cell popcount(cell x) {
  // C++20: Use std::popcount
  return std::popcount(x);
}

inline bool bitmap_p(uint8_t* bitmap, cell index) {
  cell byte = index >> 3;
  cell bit = index & 7;
  return (bitmap[byte] & (1 << bit)) != 0;
}

}
