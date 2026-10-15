// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
#pragma once
#include <stdint.h>
#include <stddef.h>

namespace factor {
// Classic SH3/SH4 instructions are 16 bits in the target byte order.
// Explicit endianness also permits testing both encodings on the build host.
inline uint16_t sh_load_instruction(const void* address, bool little_endian) {
  const auto* p = static_cast<const uint8_t*>(address);
  return little_endian ? uint16_t(p[0] | (uint16_t(p[1]) << 8))
                       : uint16_t((uint16_t(p[0]) << 8) | p[1]);
}
inline void sh_store_instruction(void* address, uint16_t value, bool little_endian) {
  auto* p = static_cast<uint8_t*>(address);
  p[little_endian ? 0 : 1] = uint8_t(value);
  p[little_endian ? 1 : 0] = uint8_t(value >> 8);
}
inline int32_t sh_signed_field(uint16_t value, unsigned bits) {
  const uint32_t mask = (uint32_t(1) << bits) - 1;
  const uint32_t field = value & mask;
  return (field & (uint32_t(1) << (bits - 1)))
      ? int32_t(field) - int32_t(uint32_t(1) << bits) : int32_t(field);
}
// BRA/BSR: PC + 4 + sign_extend(disp12)*2; BT/BF use disp8.
inline int32_t sh_branch_displacement(uint16_t instruction, unsigned bits) {
  return 4 + sh_signed_field(instruction, bits) * 2;
}
inline uint16_t sh_branch_bits(int32_t displacement, unsigned bits) {
  return uint16_t((displacement - 4) / 2) & ((uint16_t(1) << bits) - 1);
}
// MOV.L @(disp,PC),Rn rounds PC+4 down to a four-byte boundary.
inline uintptr_t sh_literal_address(uintptr_t pc, uint16_t instruction) {
  return ((pc + 4) & ~uintptr_t(3)) + (instruction & 0xff) * 4;
}
inline uint32_t sh_load_literal(const void* address, bool little_endian) {
  const auto* p = static_cast<const uint8_t*>(address);
  return little_endian
      ? uint32_t(p[0]) | (uint32_t(p[1]) << 8) | (uint32_t(p[2]) << 16) | (uint32_t(p[3]) << 24)
      : (uint32_t(p[0]) << 24) | (uint32_t(p[1]) << 16) | (uint32_t(p[2]) << 8) | uint32_t(p[3]);
}
inline void sh_store_literal(void* address, uint32_t value, bool little_endian) {
  auto* p = static_cast<uint8_t*>(address);
  for (unsigned i = 0; i < 4; ++i)
    p[little_endian ? i : 3 - i] = uint8_t(value >> (i * 8));
}
// MOV.L literal,R0; JSR/JMP @R0; NOP. PR points after the delay slot.
inline bool sh_call_site_p(const void* return_address, bool little_endian) {
  const auto* p = static_cast<const uint8_t*>(return_address);
  const uint16_t branch = sh_load_instruction(p - 4, little_endian);
  return (sh_load_instruction(p - 6, little_endian) & 0xff00) == 0xd000 &&
      (branch == 0x400b || branch == 0x402b) &&
      sh_load_instruction(p - 2, little_endian) == 0x0009;
}
inline void* sh_call_literal(const void* return_address, bool little_endian) {
  const auto* p = static_cast<const uint8_t*>(return_address) - 6;
  return reinterpret_cast<void*>(sh_literal_address(reinterpret_cast<uintptr_t>(p),
      sh_load_instruction(p, little_endian)));
}
}
