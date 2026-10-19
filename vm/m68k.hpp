#ifndef FACTOR_M68K_HPP
#define FACTOR_M68K_HPP

#include <stdint.h>
#include <string.h>

namespace factor {
// Older images assumed a 12-byte Factor prologue at this native entry.
// Match both argument loads so ordinary code is never mistaken for the stub.
inline bool m68k_legacy_unwind_arguments_p(const void* entry) {
  const uint8_t legacy[] = {0x28, 0x2f, 0x00, 0x10,
                            0x22, 0x6f, 0x00, 0x14};
  return memcmp(entry, legacy, sizeof(legacy)) == 0;
}

// Absolute long JSR/JMP operands start at a word-aligned address, not
// necessarily a cell-aligned address. Use memcpy even on a host which
// supports unaligned accesses so cross-host image tooling is safe too.
inline uint16_t m68k_call_opcode(const void* return_address) {
  const uint8_t* instruction = (const uint8_t*)return_address - 6;
  return ((uint16_t)instruction[0] << 8) | instruction[1];
}
inline bool m68k_call_site_p(const void* return_address) {
  uint16_t opcode = m68k_call_opcode(return_address);
  return opcode == 0x4eb9 || opcode == 0x4ef9;
}
inline bool m68k_tail_call_site_p(const void* return_address) {
  return m68k_call_opcode(return_address) == 0x4ef9;
}
inline uint32_t m68k_call_target(const void* return_address) {
  const uint8_t* operand = (const uint8_t*)return_address - 4;
  return ((uint32_t)operand[0] << 24) | ((uint32_t)operand[1] << 16) |
         ((uint32_t)operand[2] << 8) | operand[3];
}
inline void m68k_store_call_target(void* return_address, uint32_t target) {
  uint8_t* operand = (uint8_t*)return_address - 4;
  const uint8_t bytes[4] = {(uint8_t)(target >> 24), (uint8_t)(target >> 16),
                          (uint8_t)(target >> 8), (uint8_t)target};
  memcpy(operand, bytes, sizeof(bytes));
}
}
#endif
