// CPU interpretation of RC_NATIVE_0 and RC_NATIVE_1.
#pragma once
#include "mips.hpp"

namespace factor::cpu {
inline fixnum load_native_operand(relocation_class klass, cell pointer,
                                  cell relative_to) {
  (void)relative_to;
  if (klass == RC_NATIVE_1) {
    uint32_t instruction;
    memcpy(&instruction, (void*)(pointer - 4), 4);
    return int16_t(instruction & 0xffff);
  }
  if (sizeof(cell) == 8) {
    uint32_t words[7];
    memcpy(words, (void*)(pointer - 28), sizeof(words));
    return fixnum(mips_load_li64(words));
  }
  uint32_t words[2];
  memcpy(words, (void*)(pointer - 8), sizeof(words));
  return fixnum(mips_load_li32(words));
}

inline void store_native_operand(relocation_class klass, cell pointer,
                                  fixnum absolute) {
  if (klass == RC_NATIVE_1) {
    if (absolute < -32768 || absolute > 32767)
      critical_error("MIPS instruction immediate out of range", absolute);
    uint32_t instruction;
    memcpy(&instruction, (void*)(pointer - 4), 4);
    instruction = (instruction & 0xffff0000) | (uint32_t(absolute) & 0xffff);
    memcpy((void*)(pointer - 4), &instruction, 4);
  } else if (sizeof(cell) == 8) {
    uint32_t words[7];
    memcpy(words, (void*)(pointer - 28), sizeof(words));
    mips_store_li64(words, cell(absolute));
    memcpy((void*)(pointer - 28), words, sizeof(words));
  } else {
    uint32_t words[2];
    memcpy(words, (void*)(pointer - 8), sizeof(words));
    mips_store_li32(words, cell(absolute));
    memcpy((void*)(pointer - 8), words, sizeof(words));
  }
}
}
