// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
#pragma once
#include <cstdlib>

// SPARC instruction templates shared by image relocation and code patching.
// Instructions are always big-endian, including in a cross-image builder.
namespace factor {

inline uint32_t sparc_load_instruction(const void* address) {
  const auto* p = static_cast<const uint8_t*>(address);
  return (uint32_t(p[0]) << 24) | (uint32_t(p[1]) << 16) |
         (uint32_t(p[2]) << 8) | uint32_t(p[3]);
}

inline void sparc_store_instruction(void* address, uint32_t value) {
  auto* p = static_cast<uint8_t*>(address);
  p[0] = uint8_t(value >> 24);
  p[1] = uint8_t(value >> 16);
  p[2] = uint8_t(value >> 8);
  p[3] = uint8_t(value);
}

inline int64_t sparc_signed_field(uint32_t value, unsigned bits) {
  FACTOR_ASSERT(bits > 0 && bits <= 30);
  const uint32_t mask = (uint32_t(1) << bits) - 1;
  value &= mask;
  return (value & (uint32_t(1) << (bits - 1)))
      ? int64_t(value) - (int64_t(1) << bits) : int64_t(value);
}

inline int64_t sparc_displacement(const void* address, unsigned bits) {
  return sparc_signed_field(sparc_load_instruction(address), bits) * 4;
}

inline void sparc_store_displacement(void* address, int64_t value, unsigned bits) {
  FACTOR_ASSERT(bits > 0 && bits <= 30);
  const int64_t limit = int64_t(1) << (bits + 1);
  FACTOR_ASSERT(value >= -limit && value < limit && !(value & 3));
  (void)limit;
  const uint32_t mask = (uint32_t(1) << bits) - 1;
  const uint32_t instruction = sparc_load_instruction(address);
  sparc_store_instruction(address,
      (instruction & ~mask) | (uint32_t(value / 4) & mask));
}

inline unsigned sparc_branch_width(uint32_t instruction) {
  const unsigned op = instruction >> 30;
  if (op == 1) return 30;
  if (op != 0) return 0;
  switch ((instruction >> 22) & 7) {
    case 2: case 6: return 22;
    case 1: case 5: return 19;
    default: return 0;
  }
}
inline unsigned sparc_branch_bits(const void* address) {
  return sparc_branch_width(sparc_load_instruction(address));
}

inline int64_t sparc_branch_displacement(const void* address) {
  const unsigned width = sparc_branch_width(sparc_load_instruction(address));
  if (!width) ::abort();
  return sparc_displacement(address, width);
}
inline void sparc_store_branch(void* address, int64_t value) {
  const unsigned width = sparc_branch_width(sparc_load_instruction(address));
  if (!width) ::abort();
  sparc_store_displacement(address, value, width);
}

// SET32: SETHI rd,high22; OR rd,low10,rd.
inline uint32_t sparc_load_set32(const void* address) {
  const auto* p = static_cast<const uint8_t*>(address);
  return ((sparc_load_instruction(p) & 0x3fffff) << 10) |
         (sparc_load_instruction(p + 4) & 0x3ff);
}

inline void sparc_store_set32(void* address, uint32_t value) {
  auto* p = static_cast<uint8_t*>(address);
  sparc_store_instruction(p, (sparc_load_instruction(p) & ~uint32_t(0x3fffff)) |
                            (value >> 10));
  sparc_store_instruction(p + 4, (sparc_load_instruction(p + 4) & ~uint32_t(0x3ff)) |
                                (value & 0x3ff));
}

// SET64: SET32 scratch,high32; SLLX scratch,32,scratch;
// SET32 rd,low32; OR rd,scratch,rd (six instructions).
inline uint64_t sparc_load_set64(const void* address) {
  const auto* p = static_cast<const uint8_t*>(address);
  return (uint64_t(sparc_load_set32(p)) << 32) | sparc_load_set32(p + 12);
}

inline void sparc_store_set64(void* address, uint64_t value) {
  auto* p = static_cast<uint8_t*>(address);
  sparc_store_set32(p, uint32_t(value >> 32));
  sparc_store_set32(p + 12, uint32_t(value));
}

}
