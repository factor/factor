/* Ordinary m88k C++ runtime RMW helpers. These are deliberately locked:
 * they are neither lock-free nor suitable for asynchronous signal handlers.
 * LLVM's outlined ABI passes the value before the address and returns old. */
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>

static pthread_mutex_t atomic_lock = PTHREAD_MUTEX_INITIALIZER;
static void lock_atomic(void) {
  if (pthread_mutex_lock(&atomic_lock)) abort();
}
static void unlock_atomic(void) {
  if (pthread_mutex_unlock(&atomic_lock)) abort();
}
#define RMW(name, expression) \
uint32_t __m88k_locked_##name##4(uint32_t value, volatile uint32_t *address) { \
  uint32_t old; \
  lock_atomic(); \
  old = *address; \
  *address = (expression); \
  unlock_atomic(); \
  return old; \
}
RMW(add, old + value)
RMW(exchange, value)
RMW(clear, old & ~value)
RMW(or, old | value)
RMW(xor, old ^ value)
uint32_t __m88k_locked_cas4(uint32_t expected, uint32_t desired,
                            volatile uint32_t *address) {
  uint32_t old;
  lock_atomic();
  old = *address;
  if (old == expected) *address = desired;
  unlock_atomic();
  return old;
}
