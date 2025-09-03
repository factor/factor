#define FACTOR_FORCE_INLINE __attribute__((always_inline)) inline
namespace factor {
namespace atomic {
__attribute__((always_inline)) inline static bool cas(volatile cell* ptr,
                                                      cell old_val,
                                                      cell new_val) {
  return __sync_bool_compare_and_swap(ptr, old_val, new_val);
}
__attribute__((always_inline)) inline static bool cas(volatile fixnum* ptr,
                                                      fixnum old_val,
                                                      fixnum new_val) {
  return __sync_bool_compare_and_swap(ptr, old_val, new_val);
}

__attribute__((always_inline)) inline static cell fetch_add(volatile cell* ptr,
                                                            cell val) {
  return __sync_fetch_and_add(ptr, val);
}
__attribute__((always_inline)) inline static fixnum fetch_add(
    volatile fixnum* ptr, fixnum val) {
  return __sync_fetch_and_add(ptr, val);
}

__attribute__((always_inline)) inline static cell fetch_subtract(
    volatile cell* ptr, cell val) {
  return __sync_fetch_and_sub(ptr, val);
}
__attribute__((always_inline)) inline static fixnum fetch_subtract(
    volatile fixnum* ptr, fixnum val) {
  return __sync_fetch_and_sub(ptr, val);
}

__attribute__((always_inline)) inline static void fence() {
  __sync_synchronize();
}
}
}

#include "atomic.hpp"
