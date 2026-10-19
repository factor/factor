#ifndef FACTOR_IEEE_INTEGER_HPP
#define FACTOR_IEEE_INTEGER_HPP

#include <stdint.h>

namespace factor {

// Truncate IEEE binary64 to magnitude digits without native floating point.
inline unsigned ieee_integer_length(uint64_t bits, unsigned digit_bits) {
  unsigned exponent = (unsigned)((bits >> 52) & 0x7ff);
  if (exponent < 1023 || exponent == 2047) return 0;
  return (exponent - 1023 + digit_bits) / digit_bits;
}

inline uint64_t ieee_integer_digit(uint64_t bits, unsigned digit_bits,
                                   unsigned index) {
  unsigned exponent = (unsigned)((bits >> 52) & 0x7ff);
  if (exponent < 1023 || exponent == 2047) return 0;
  uint64_t significand = (bits & UINT64_C(0x000fffffffffffff)) |
                         UINT64_C(0x0010000000000000);
  int source = (int)(index * digit_bits) - ((int)exponent - 1075);
  uint64_t digit = 0;
  if (source >= 0 && source < 53) digit = significand >> source;
  else if (source < 0 && source > -(int)digit_bits) digit = significand << -source;
  return digit & ((UINT64_C(1) << digit_bits) - 1);
}

}
#endif
