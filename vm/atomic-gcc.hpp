#define FACTOR_FORCE_INLINE __attribute__((always_inline)) inline
#include "atomic.hpp"
#ifdef FACTOR_ATOMIC_RMW_UNAVAILABLE
#include <stdlib.h>
#endif
namespace factor {
namespace atomic {
__attribute__((always_inline)) inline static bool cas(volatile cell* ptr,
                                                      cell old_val,
                                                      cell new_val) {
#if defined(FACTOR_ATOMIC_RMW_UNAVAILABLE)
  ::abort();
#elif defined(FACTOR_OPENBSD_HPPA_MASKED_RMW)
  return openbsd_hppa::cas(reinterpret_cast<volatile uint32_t*>(ptr), old_val, new_val);
#elif defined(FACTOR_NETBSD_RAS)
  return ras::cas(reinterpret_cast<volatile uint32_t*>(ptr), old_val, new_val);
#else
  return __sync_bool_compare_and_swap(ptr, old_val, new_val);
#endif
}
__attribute__((always_inline)) inline static bool cas(volatile fixnum* ptr,
                                                      fixnum old_val,
                                                      fixnum new_val) {
#if defined(FACTOR_ATOMIC_RMW_UNAVAILABLE)
  ::abort();
#elif defined(FACTOR_OPENBSD_HPPA_MASKED_RMW)
  return openbsd_hppa::cas(reinterpret_cast<volatile uint32_t*>(ptr), old_val, new_val);
#elif defined(FACTOR_NETBSD_RAS)
  return ras::cas(reinterpret_cast<volatile uint32_t*>(ptr), old_val, new_val);
#else
  return __sync_bool_compare_and_swap(ptr, old_val, new_val);
#endif
}

__attribute__((always_inline)) inline static cell fetch_add(volatile cell* ptr,
                                                            cell val) {
#if defined(FACTOR_ATOMIC_RMW_UNAVAILABLE)
  ::abort();
#elif defined(FACTOR_OPENBSD_HPPA_MASKED_RMW)
  return openbsd_hppa::fetch_add(reinterpret_cast<volatile uint32_t*>(ptr), val);
#elif defined(FACTOR_NETBSD_RAS)
  return ras::fetch_add(reinterpret_cast<volatile uint32_t*>(ptr), val);
#else
  return __sync_fetch_and_add(ptr, val);
#endif
}
__attribute__((always_inline)) inline static fixnum fetch_add(
    volatile fixnum* ptr, fixnum val) {
#if defined(FACTOR_ATOMIC_RMW_UNAVAILABLE)
  ::abort();
#elif defined(FACTOR_OPENBSD_HPPA_MASKED_RMW)
  return openbsd_hppa::fetch_add(reinterpret_cast<volatile uint32_t*>(ptr), val);
#elif defined(FACTOR_NETBSD_RAS)
  return ras::fetch_add(reinterpret_cast<volatile uint32_t*>(ptr), val);
#else
  return __sync_fetch_and_add(ptr, val);
#endif
}

__attribute__((always_inline)) inline static cell fetch_subtract(
    volatile cell* ptr, cell val) {
#if defined(FACTOR_ATOMIC_RMW_UNAVAILABLE)
  ::abort();
#elif defined(FACTOR_OPENBSD_HPPA_MASKED_RMW)
  return openbsd_hppa::fetch_add(reinterpret_cast<volatile uint32_t*>(ptr),
                              uint32_t(0) - uint32_t(val));
#elif defined(FACTOR_NETBSD_RAS)
  return ras::fetch_add(reinterpret_cast<volatile uint32_t*>(ptr),
                        uint32_t(0) - uint32_t(val));
#else
  return __sync_fetch_and_sub(ptr, val);
#endif
}
__attribute__((always_inline)) inline static fixnum fetch_subtract(
    volatile fixnum* ptr, fixnum val) {
#if defined(FACTOR_ATOMIC_RMW_UNAVAILABLE)
  ::abort();
#elif defined(FACTOR_OPENBSD_HPPA_MASKED_RMW)
  return openbsd_hppa::fetch_add(reinterpret_cast<volatile uint32_t*>(ptr),
                              uint32_t(0) - uint32_t(val));
#elif defined(FACTOR_NETBSD_RAS)
  return ras::fetch_add(reinterpret_cast<volatile uint32_t*>(ptr),
                        uint32_t(0) - uint32_t(val));
#else
  return __sync_fetch_and_sub(ptr, val);
#endif
}

__attribute__((always_inline)) inline static void fence() {
#if defined(__m88k__) || defined(__m88000__)
  // The marked backend lowers this to the OpenBSD TB1 128 memory barrier.
  __atomic_thread_fence(__ATOMIC_SEQ_CST);
#else
  __sync_synchronize();
#endif
}
}
}
