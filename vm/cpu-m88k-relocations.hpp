// CPU interpretation of RC_NATIVE_0 and RC_NATIVE_1.
#pragma once
#include "m88k.hpp"

namespace factor::cpu {
inline fixnum load_native_operand(relocation_class klass, cell pointer,
                                  cell relative_to) {
  if (klass == RC_NATIVE_0)
    return m88k_load_literal32((const uint32_t*)(pointer - 8));
  uint32_t instruction;
  memcpy(&instruction, (void*)(pointer - 4), sizeof(instruction));
  return relative_to - 4 + m88k_branch_displacement(instruction);
}

inline void store_native_operand(relocation_class klass, cell pointer,
                                  fixnum absolute) {
  if (klass == RC_NATIVE_0)
    m88k_store_literal32((uint32_t*)(pointer - 8), uint32_t(absolute));
  else
    m88k_store_branch((uint32_t*)(pointer - 4), int32_t(absolute - pointer + 4));
}
}
