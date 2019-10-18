#define FACTOR_FORCE_INLINE __forceinline

namespace factor {
namespace atomic {
__forceinline static bool cas(volatile cell* ptr, cell old_val, cell new_val) {
  return InterlockedCompareExchange(reinterpret_cast<volatile LONG*>(ptr),
                                    (LONG) old_val, (LONG) new_val) ==
         (LONG) old_val;
}
__forceinline static bool cas(volatile fixnum* ptr, fixnum old_val,
                              fixnum new_val) {
  return InterlockedCompareExchange(reinterpret_cast<volatile LONG*>(ptr),
                                    (LONG) old_val, (LONG) new_val) ==
         (LONG) old_val;
}

__forceinline static cell fetch_add(volatile cell* ptr, cell val) {
  return (cell)InterlockedExchangeAdd(reinterpret_cast<volatile LONG*>(ptr),
                                      (LONG) val);
}
__forceinline static fixnum fetch_add(volatile fixnum* ptr, fixnum val) {
  return (fixnum)InterlockedExchangeAdd(reinterpret_cast<volatile LONG*>(ptr),
                                        (LONG) val);
}

__forceinline static cell fetch_subtract(volatile cell* ptr, cell val) {
  return (cell)InterlockedExchangeAdd(reinterpret_cast<volatile LONG*>(ptr),
                                      -(LONG)val);
}
__forceinline static fixnum fetch_subtract(volatile fixnum* ptr, fixnum val) {
  return (fixnum)InterlockedExchangeAdd(reinterpret_cast<volatile LONG*>(ptr),
                                        -(LONG)val);
}

__forceinline static void fence() { MemoryBarrier(); }
}
}

#include "atomic.hpp"
