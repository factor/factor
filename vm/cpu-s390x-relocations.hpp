// CPU interpretation of RC_NATIVE_0 and RC_NATIVE_1.
#pragma once
#include "s390x.hpp"

namespace factor::cpu {
inline fixnum load_native_operand(relocation_class klass, cell pointer,
                                  cell relative_to) {
  if (klass == RC_NATIVE_1)
    return fixnum(s390x_load_immediate((const unsigned char*)(pointer - 12)));
  return fixnum(relative_to - 6 + cell(s390x_branch_displacement(
      (const unsigned char*)(pointer - 6))));
}

inline void store_native_operand(relocation_class klass, cell pointer,
                                  fixnum absolute) {
  if (klass == RC_NATIVE_1)
    s390x_store_immediate((unsigned char*)(pointer - 12), cell(absolute));
  else {
    const fixnum displacement = fixnum(cell(absolute) - pointer + 6);
    if ((displacement & 1) || displacement < INT64_C(-4294967296) ||
        displacement > INT64_C(4294967294))
      critical_error("System z branch displacement out of range", displacement);
    s390x_store_branch((unsigned char*)(pointer - 6), displacement);
  }
}
}
