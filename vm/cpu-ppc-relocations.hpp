// CPU interpretation of RC_NATIVE_0 and RC_NATIVE_1.
#pragma once
#include "powerpc.hpp"

namespace factor::cpu {
inline fixnum load_native_operand(relocation_class klass, cell pointer,
                                  cell relative_to) {
  return klass == RC_NATIVE_0 ? ppc_load_absolute(pointer)
                              : ppc_load_relative(pointer, relative_to);
}

inline void store_native_operand(relocation_class klass, cell pointer,
                                  fixnum absolute) {
  if (klass == RC_NATIVE_0) ppc_store_absolute(pointer, absolute);
  else ppc_store_relative(pointer, absolute);
}
}
