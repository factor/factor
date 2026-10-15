// CPU interpretation of RC_NATIVE_0 and RC_NATIVE_1.
#pragma once
#include "loongarch.hpp"

namespace factor { namespace cpu {
inline fixnum load_native_operand(relocation_class klass, cell pointer,
                                  cell relative_to) {
  if (klass == RC_NATIVE_1)
    return fixnum(loongarch_load_literal((const uint32_t*)(pointer - 32)));
  return fixnum(relative_to - 8 + loongarch_pair_displacement((const uint32_t*)(pointer - 8)));
}

inline void store_native_operand(relocation_class klass, cell pointer,
                                  fixnum absolute) {
  if (klass == RC_NATIVE_1)
    loongarch_store_literal((uint32_t*)(pointer - 32), cell(absolute));
  else
    loongarch_store_pair((uint32_t*)(pointer - 8), int64_t(absolute) - int64_t(pointer - 8));
}
}}
