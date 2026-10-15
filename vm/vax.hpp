#ifndef FACTOR_VAX_HPP
#define FACTOR_VAX_HPP

#include <stdint.h>
#include <string.h>

namespace factor {

// Factor calls use JSB/RSB; the native CALLS/RET procedure ABI is separate.
// JSB/JMP with an absolute-deferred operand have a fixed six-byte encoding.
inline unsigned char vax_call_opcode(const void* return_address) {
  return *((const unsigned char*)return_address - 6);
}

inline bool vax_call_site_p(const void* return_address) {
  const unsigned char* instruction = (const unsigned char*)return_address - 6;
  return (instruction[0] == 0x16 || instruction[0] == 0x17) &&
         instruction[1] == 0x9f;
}

inline bool vax_tail_call_site_p(const void* return_address) {
  return vax_call_opcode(return_address) == 0x17;
}

inline uint32_t vax_call_target(const void* return_address) {
  const unsigned char* operand = (const unsigned char*)return_address - 4;
  return (uint32_t)operand[0] | ((uint32_t)operand[1] << 8) |
         ((uint32_t)operand[2] << 16) | ((uint32_t)operand[3] << 24);
}

inline void vax_store_call_target(void* return_address, uint32_t target) {
  unsigned char* operand = (unsigned char*)return_address - 4;
  const unsigned char bytes[] = {(unsigned char)target,
                                (unsigned char)(target >> 8),
                                (unsigned char)(target >> 16),
                                (unsigned char)(target >> 24)};
  memcpy(operand, bytes, sizeof(bytes));
}

}

#endif
