#pragma once

namespace factor {
// OR.U/OR encode an absolute 32-bit literal in two native-endian words.
inline uint32_t m88k_load_literal32(const uint32_t* words) {
  return (words[0] & 0xffff) << 16 | (words[1] & 0xffff);
}
inline void m88k_store_literal32(uint32_t* words, uint32_t value) {
  words[0] = (words[0] & 0xffff0000) | (value >> 16);
  words[1] = (words[1] & 0xffff0000) | (value & 0xffff);
}
inline int32_t m88k_branch_displacement(uint32_t instruction) {
  uint32_t field = instruction & 0x03ffffff;
  int32_t signed_field = (field & 0x02000000)
      ? int32_t(field | 0xfc000000) : int32_t(field);
  return signed_field * 4;
}
inline void m88k_store_branch(uint32_t* instruction, int32_t displacement) {
  FACTOR_ASSERT((displacement & 3) == 0);
  FACTOR_ASSERT(displacement >= -0x08000000 && displacement <= 0x07fffffc);
  *instruction = (*instruction & 0xfc000000) |
                 (uint32_t(displacement / 4) & 0x03ffffff);
}
}
