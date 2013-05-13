#define FACTOR_FORCE_INLINE __forceinline

namespace factor {
namespace atomic {
__forceinline static bool cas(volatile cell* ptr, cell old_val, cell new_val) {
  return InterlockedCompareExchange64(reinterpret_cast<volatile LONG64*>(ptr),
                                      (LONG64)old_val, (LONG64)new_val) ==
         (LONG64)old_val;
}
__forceinline static bool cas(volatile fixnum* ptr, fixnum old_val,
                              fixnum new_val) {
  return InterlockedCompareExchange64(reinterpret_cast<volatile LONG64*>(ptr),
                                      (LONG64)old_val, (LONG64)new_val) ==
         (LONG64)old_val;
}

__forceinline static cell fetch_add(volatile cell* ptr, cell val) {
  return (cell)InterlockedExchangeAdd64(
      reinterpret_cast<volatile LONG64*>(ptr), (LONG64)val);
}
__forceinline static fixnum fetch_add(volatile fixnum* ptr, fixnum val) {
  return (fixnum)InterlockedExchangeAdd64(
      reinterpret_cast<volatile LONG64*>(ptr), (LONG64)val);
}

__forceinline static cell fetch_subtract(volatile cell* ptr, cell val) {
  return (cell)InterlockedExchangeAdd64(
      reinterpret_cast<volatile LONG64*>(ptr), -(LONG64)val);
}
__forceinline static fixnum fetch_subtract(volatile fixnum* ptr, fixnum val) {
  return (fixnum)InterlockedExchangeAdd64(
      reinterpret_cast<volatile LONG64*>(ptr), -(LONG64)val);
}

__forceinline static void fence() { MemoryBarrier(); }
}
}

#include "atomic.hpp"
