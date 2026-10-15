#ifndef FACTOR_VM_FLOAT_HPP
#define FACTOR_VM_FLOAT_HPP

#include <stdint.h>
#include <string.h>
#if defined(__vax__)
#include "vax_float.hpp"
#include "ieee_decimal.hpp"
#include "ieee_integer.hpp"
#endif

namespace factor {

// Images and boxed floats contain IEEE binary64, including on a native VAX.
// The C ABI's float/double types remain separate at foreign-call boundaries.
#if defined(FACTOR_INTEGER_ONLY)
// Opaque IEEE payload: no arithmetic operators or native floating conversion.
struct vm_float { uint64_t payload; };
static_assert(sizeof(vm_float) == 8, "image float payload must remain binary64");
#elif defined(__vax__)
using vm_float = ieee_binary64;
#else
using vm_float = double;
#endif

inline uint64_t vm_float_bits(vm_float value) {
  uint64_t bits;
  memcpy(&bits, &value, sizeof(bits));
  return bits;
}

inline vm_float vm_float_from_bits(uint64_t bits) {
#if defined(FACTOR_INTEGER_ONLY)
  return vm_float{bits};
#elif defined(__vax__)
  return vm_float::from_bits(bits);
#else
  vm_float value;
  memcpy(&value, &bits, sizeof(value));
  return value;
#endif
}

#if !defined(FACTOR_INTEGER_ONLY)
inline vm_float vm_float_from_signed(int64_t value) {
#if defined(__vax__)
  return vm_float::from_signed(value);
#else
  return (double)value;
#endif
}

inline int64_t vm_float_to_signed(vm_float value) {
#if defined(__vax__)
  return value.to_signed();
#else
  return (int64_t)value;
#endif
}

#endif // !FACTOR_INTEGER_ONLY

}

#endif
