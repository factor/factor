// CPU interpretation of RC_NATIVE_0 and RC_NATIVE_1.
#pragma once

namespace factor::cpu {
inline fixnum load_native_operand(relocation_class klass, cell pointer,
                                  cell relative_to) {
  (void)pointer; (void)relative_to;
  critical_error("Native relocation class is unsupported on this CPU", klass);
  return 0;
}

inline void store_native_operand(relocation_class klass, cell pointer,
                                  fixnum absolute) {
  (void)pointer; (void)absolute;
  critical_error("Native relocation class is unsupported on this CPU", klass);
}
}
