// CPU interpretation of RC_NATIVE_0 and RC_NATIVE_1.
#pragma once
#include "sparc.hpp"

namespace factor::cpu {
inline fixnum load_native_operand(relocation_class klass, cell pointer,
                                  cell relative_to) {
  if (klass == RC_NATIVE_1)
    return sizeof(cell) == 8 ? fixnum(sparc_load_set64((void*)(pointer - 24)))
                            : fixnum(sparc_load_set32((void*)(pointer - 8)));
  const unsigned bits = sparc_branch_bits((void*)(pointer - 4));
  if (!bits) critical_error("Unsupported SPARC branch template", pointer);
  return fixnum(relative_to - 4 + cell(sparc_displacement((void*)(pointer - 4), bits)));
}

inline void store_native_operand(relocation_class klass, cell pointer,
                                  fixnum absolute) {
  if (klass == RC_NATIVE_1) {
    if (sizeof(cell) == 8) sparc_store_set64((void*)(pointer - 24), cell(absolute));
    else sparc_store_set32((void*)(pointer - 8), cell(absolute));
  } else {
    const unsigned bits = sparc_branch_bits((void*)(pointer - 4));
    if (!bits) critical_error("Unsupported SPARC branch template", pointer);
    const fixnum displacement = fixnum(cell(absolute) - pointer + 4);
    const int64_t limit = INT64_C(1) << (bits + 1);
    if ((displacement & 3) || displacement < -limit || displacement >= limit)
      critical_error("SPARC branch displacement out of range", displacement);
    sparc_store_displacement((void*)(pointer - 4), displacement, bits);
  }
}
}
