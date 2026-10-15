// CPU interpretation of RC_NATIVE_0 and RC_NATIVE_1.
#pragma once

namespace factor { namespace cpu {
inline fixnum load_native_operand(relocation_class klass, cell pointer,
                                  cell relative_to) {
  (void)relative_to;
  if (klass == RC_NATIVE_1) {
    cell literal;
    memcpy(&literal, (void*)(pointer - 28), sizeof(literal));
    return fixnum(literal);
  }
  uint32_t instruction;
  memcpy(&instruction, (void*)(pointer - 4), sizeof(instruction));
  fixnum displacement = instruction & 0x1fffff;
  if (displacement & 0x100000) displacement -= 0x200000;
  return relative_to + displacement * 4;
}

inline void store_native_operand(relocation_class klass, cell pointer,
                                  fixnum absolute) {
  if (klass == RC_NATIVE_1) {
    memcpy((void*)(pointer - 28), &absolute, sizeof(absolute));
  } else {
    fixnum displacement = absolute - pointer;
    if ((displacement & 3) || displacement < -4194304 || displacement > 4194300)
      critical_error("Alpha branch displacement out of range", displacement);
    uint32_t instruction;
    memcpy(&instruction, (void*)(pointer - 4), sizeof(instruction));
    instruction = (instruction & 0xffe00000) | ((uint32_t)(displacement / 4) & 0x1fffff);
    memcpy((void*)(pointer - 4), &instruction, sizeof(instruction));
  }
}
}}
