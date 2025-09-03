#define FACTOR_FORCE_INLINE __attribute__((always_inline)) inline
namespace factor {
namespace atomic {
__attribute__((always_inline)) inline static bool cas(volatile cell* ptr,
                                                      cell old_val,
                                                      cell new_val) {
  return __atomic_compare_exchange_n(ptr, &old_val, new_val, false, 
                                     __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
}
__attribute__((always_inline)) inline static bool cas(volatile fixnum* ptr,
                                                      fixnum old_val,
                                                      fixnum new_val) {
  return __atomic_compare_exchange_n(ptr, &old_val, new_val, false,
                                     __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
}

__attribute__((always_inline)) inline static cell fetch_add(volatile cell* ptr,
                                                            cell val) {
  return __atomic_fetch_add(ptr, val, __ATOMIC_SEQ_CST);
}
__attribute__((always_inline)) inline static fixnum fetch_add(
    volatile fixnum* ptr, fixnum val) {
  return __atomic_fetch_add(ptr, val, __ATOMIC_SEQ_CST);
}

__attribute__((always_inline)) inline static cell fetch_subtract(
    volatile cell* ptr, cell val) {
  return __atomic_fetch_sub(ptr, val, __ATOMIC_SEQ_CST);
}
__attribute__((always_inline)) inline static fixnum fetch_subtract(
    volatile fixnum* ptr, fixnum val) {
  return __atomic_fetch_sub(ptr, val, __ATOMIC_SEQ_CST);
}

__attribute__((always_inline)) inline static void fence() {
  __atomic_thread_fence(__ATOMIC_SEQ_CST);
}
}
}

#include "atomic.hpp"
