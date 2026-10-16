#pragma once
#include "openrisc.hpp"

namespace factor::cpu {
inline fixnum load_native_operand(relocation_class klass, cell pointer, cell relative_to) {
  (void)relative_to;
  if (klass == RC_NATIVE_1) {
    uint32_t instruction;
    memcpy(&instruction, (void*)(pointer - 4), 4);
    return int16_t(instruction & 0xffff);
  }
  uint32_t words[2];
  memcpy(words, (void*)(pointer - 8), sizeof(words));
  return fixnum(openrisc_load_li32(words));
}
inline void store_native_operand(relocation_class klass, cell pointer, fixnum absolute) {
  if (klass == RC_NATIVE_1) {
    if (absolute < -32768 || absolute > 32767)
      critical_error("OpenRISC instruction immediate out of range", absolute);
    uint32_t instruction;
    memcpy(&instruction, (void*)(pointer - 4), 4);
    instruction = (instruction & 0xffff0000) | (uint32_t(absolute) & 0xffff);
    memcpy((void*)(pointer - 4), &instruction, 4);
  } else {
    uint32_t words[2];
    memcpy(words, (void*)(pointer - 8), sizeof(words));
    openrisc_store_li32(words, uint32_t(absolute));
    memcpy((void*)(pointer - 8), words, sizeof(words));
  }
}
}
