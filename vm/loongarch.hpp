// LoongArch64 fixed-width instruction operands. Slot 14 is a PC-relative
// PCADDU12I pair, slot 15 is an eight-instruction signed-digit literal.
#pragma once
namespace factor {
inline int64_t loongarch_signed(uint32_t n, unsigned bits) {
  uint32_t mask = (uint32_t(1) << bits) - 1;
  n &= mask;
  return (n & (uint32_t(1) << (bits - 1)))
    ? int64_t(n) - (int64_t(1) << bits) : int64_t(n);
}
inline bool loongarch_jirl(uint32_t p) {
  return (p & 0xfc000000) == 0x4c000000;
}
inline int64_t loongarch_pair_displacement(const uint32_t* p) {
  return loongarch_signed(p[0] >> 5, 20) * 4096 +
    (loongarch_jirl(p[1]) ? loongarch_signed(p[1] >> 10, 16) * 4
                         : loongarch_signed(p[1] >> 10, 12));
}
inline void loongarch_store_pair(uint32_t* p, int64_t value) {
  int64_t low = loongarch_signed(uint32_t(value), 12);
  int64_t high = (value - low) / 4096;
  FACTOR_ASSERT(high >= -524288 && high < 524288);
  p[0] = (p[0] & 0xfe00001f) | ((uint32_t(high) & 0xfffff) << 5);
  if (loongarch_jirl(p[1])) {
    FACTOR_ASSERT(!(low & 3));
    p[1] = (p[1] & 0xfc0003ff) | ((uint32_t(low / 4) & 0xffff) << 10);
  } else {
    p[1] = (p[1] & 0xffc003ff) | ((uint32_t(low) & 0xfff) << 10);
  }
}
inline uint64_t loongarch_load_literal(const uint32_t* p) {
  uint64_t value = uint64_t(loongarch_signed(p[0] >> 5, 20) * 4096 +
                          loongarch_signed(p[1] >> 10, 12));
  for (unsigned i = 3; i < 8; i += 2)
    value = (value << 12) + uint64_t(loongarch_signed(p[i] >> 10, 12));
  return value;
}
inline void loongarch_store_literal(uint32_t* p, uint64_t value) {
  int64_t v = int64_t(value);
  for (int i = 7; i >= 1; i -= 2) {
    int64_t low = loongarch_signed(uint32_t(v), 12);
    p[i] = (p[i] & 0xffc003ff) | ((uint32_t(low) & 0xfff) << 10);
    v = (v >> 12) + (low < 0);
  }
  p[0] = (p[0] & 0xfe00001f) | ((uint32_t(v) & 0xfffff) << 5);
}
}
