#ifndef FACTOR_SOFTWARE_FP_STATE_HPP
#define FACTOR_SOFTWARE_FP_STATE_HPP

#include <stdint.h>
#include <signal.h>
#include "ieee_float.hpp"

namespace factor {

using software_fp_trap_handler = void (*)(uint_fast8_t);
inline thread_local volatile sig_atomic_t software_fp_flags = 0;
inline thread_local uint_fast8_t software_fp_trap_mask = 0;
inline thread_local fp::rounding_mode software_fp_rounding = fp::rounding_mode::nearest_even;
inline thread_local software_fp_trap_handler software_fp_trap = nullptr;

// Retain flags in bits0..4, enabled traps in bits8..12, rounding in16..18.
inline uint32_t software_fp_get_state() {
  return (uint32_t)software_fp_flags |
         ((uint32_t)software_fp_trap_mask << 8) |
         ((uint32_t)software_fp_rounding << 16);
}

inline void software_fp_set_state(uint32_t state) {
  software_fp_flags = state & 0x1f;
  software_fp_trap_mask = (state >> 8) & 0x1f;
  software_fp_rounding = fp::rounding_mode((state >> 16) & 7);
}

inline void software_fp_raise_flags(fp::exception_flags raised) {
  // Publish before callbacks. Nested arithmetic and explicit handler clears
  // are never overwritten by destructor-time state restoration.
  software_fp_flags = software_fp_flags | raised;
  uint_fast8_t enabled = raised & software_fp_trap_mask;
  if (enabled && software_fp_trap) software_fp_trap(enabled);
}
template<class T> inline T software_fp_commit(fp::result<T> operation) {
  software_fp_raise_flags(operation.raised);
  return operation.value;
}

}
#endif
