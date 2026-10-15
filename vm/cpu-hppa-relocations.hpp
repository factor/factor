// CPU interpretation of RC_NATIVE_0 and RC_NATIVE_1.
#pragma once
#include "hppa.hpp"

namespace factor { namespace cpu {
inline fixnum load_native_operand(relocation_class klass, cell pointer,
                                  cell relative_to) {
  (void)relative_to;
  const auto* p = (const uint32_t*)pointer;
  return klass == RC_NATIVE_0 ? fixnum(hppa_load_address(p - 2))
                             : fixnum(hppa_decode_14(p[-1] & 0x3fff));
}

inline void store_native_operand(relocation_class klass, cell pointer,
                                  fixnum absolute) {
  auto* p = (uint32_t*)pointer;
  if (klass == RC_NATIVE_0) hppa_store_address(p - 2, cell(absolute));
  else {
    if (absolute < -8192 || absolute > 8191)
      critical_error("HPPA signed immediate out of range", absolute);
    p[-1] = (p[-1] & ~0x3fffu) | hppa_encode_14(absolute);
  }
}
}}
