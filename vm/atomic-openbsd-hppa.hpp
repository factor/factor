#pragma once
#if defined(__OpenBSD__) && defined(__hppa__) && __SIZEOF_POINTER__ == 4
#include <stdint.h>
#include <signal.h>
#include <pthread.h>
#include <stdlib.h>
#include <errno.h>

// OpenBSD exposes no user RAS. Mask this native thread before taking LDCW so
// a signal cannot interrupt its lock owner. Foreign signal handlers may wait
// for the bounded load/store section on another thread. Restore the exact mask
// only after releasing the lock; pending signals are then delivered normally.
#define FACTOR_OPENBSD_HPPA_MASKED_RMW 1
namespace factor { namespace atomic { namespace openbsd_hppa {
alignas(16) inline volatile uint32_t lock_word = 1;
inline thread_local sigset_t fork_mask;
inline bool supported;
inline uint32_t take_lock() {
  uint32_t previous;
  asm volatile("ldcw 0(%1),%0" : "=r"(previous) : "r"(&lock_word) : "memory");
  return previous;
}
inline void unlock() { __atomic_store_n(&lock_word, uint32_t(1), __ATOMIC_SEQ_CST); }
inline void block_signals(sigset_t* previous) {
  sigset_t all;
  if (sigfillset(&all) || sigprocmask(SIG_BLOCK, &all, previous)) abort();
}
inline void restore_signals(const sigset_t* previous) {
  if (sigprocmask(SIG_SETMASK, previous, nullptr)) abort();
}
struct guard {
  sigset_t previous;
  int saved_errno;
  guard() : saved_errno(errno) {
    block_signals(&previous);
    while (!take_lock()) {}
    __sync_synchronize();
  }
  ~guard() {
    __sync_synchronize();
    unlock();
    restore_signals(&previous);
    errno = saved_errno;
  }
};
inline void before_fork() { block_signals(&fork_mask); }
inline void after_fork_parent() { restore_signals(&fork_mask); }
inline void after_fork_child() { unlock(); restore_signals(&fork_mask); }
inline bool initialize() {
  static const bool registered =
      pthread_atfork(before_fork, after_fork_parent, after_fork_child) == 0;
  __atomic_store_n(&supported, registered, __ATOMIC_SEQ_CST);
  return registered;
}
inline bool available() { return __atomic_load_n(&supported, __ATOMIC_SEQ_CST); }
template <typename T>
inline void store(volatile T* ptr, T val) {
  static_assert(sizeof(T) == 4, "HPPA RMW store width");
  // Initialization precedes VM publication. Before it, or after a failed
  // registration, arithmetic RMW remains unavailable and publication stays
  // an indivisible native store. Once enabled, stores must join the RMW lock.
  if (!available()) {
    __atomic_store_n(ptr, val, __ATOMIC_SEQ_CST);
    return;
  }
  guard held;
  __atomic_store_n(ptr, val, __ATOMIC_SEQ_CST);
}
inline uint32_t fetch_add(volatile uint32_t* ptr, uint32_t val) {
  if (!available()) abort();
  guard held;
  uint32_t previous = __atomic_load_n(ptr, __ATOMIC_SEQ_CST);
  __atomic_store_n(ptr, previous + val, __ATOMIC_SEQ_CST);
  return previous;
}
inline bool cas(volatile uint32_t* ptr, uint32_t old_val, uint32_t new_val) {
  if (!available()) abort();
  guard held;
  uint32_t previous = __atomic_load_n(ptr, __ATOMIC_SEQ_CST);
  if (previous != old_val) return false;
  __atomic_store_n(ptr, new_val, __ATOMIC_SEQ_CST);
  return true;
}
} } }

#endif
