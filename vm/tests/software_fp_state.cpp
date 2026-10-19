#include "../ieee_binary64.hpp"
#include <assert.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>

using factor::ieee_binary64;
static volatile sig_atomic_t signals;
static volatile sig_atomic_t observed_flags;

static void handler(int) {
  ++signals;
  observed_flags = factor::software_fp_flags;
}
static void trap(uint_fast8_t) { assert(raise(SIGFPE) == 0); }
static void nested_trap(uint_fast8_t enabled) {
  assert(enabled == factor::fp::inexact);
  assert(factor::software_fp_flags & factor::fp::inexact);
  factor::software_fp_trap_mask = 0;
  const auto minus_one = ieee_binary64::from_bits(UINT64_C(0xbff0000000000000));
  assert(minus_one.sqrt().is_nan());
  assert(factor::software_fp_flags == (factor::fp::inexact | factor::fp::invalid));
}
static void clearing_trap(uint_fast8_t) { factor::software_fp_flags = 0; }

static void* other_thread(void*) {
  assert(factor::software_fp_get_state() == 0);
  assert(factor::software_fp_trap == nullptr);
  factor::software_fp_set_state((uint32_t(factor::fp::rounding_mode::downward) << 16) |
                               (factor::fp::invalid << 8));
  assert(factor::software_fp_get_state() != 0);
  return nullptr;
}

int main() {
  const auto one = ieee_binary64::from_bits(UINT64_C(0x3ff0000000000000));
  const auto halfway = ieee_binary64::from_bits(UINT64_C(0x3ca0000000000000));
  factor::software_fp_set_state(0);
  assert((one + halfway).bits() == one.bits());
  assert(factor::software_fp_flags == factor::fp::inexact);
  factor::software_fp_set_state(uint32_t(factor::fp::rounding_mode::upward) << 16);
  assert((one + halfway).bits() == one.bits() + 1);
  factor::software_fp_set_state(uint32_t(factor::fp::rounding_mode::downward) << 16);
  assert((-one - halfway).bits() == (-one).bits() + 1);
  factor::software_fp_set_state(uint32_t(factor::fp::rounding_mode::toward_zero) << 16);
  assert((-one - halfway).bits() == (-one).bits());

  struct sigaction action = {};
  action.sa_handler = handler;
  sigemptyset(&action.sa_mask);
  assert(sigaction(SIGFPE, &action, nullptr) == 0);
  factor::software_fp_trap = trap;
  factor::software_fp_set_state(factor::fp::inexact << 8);
  assert((one + halfway).bits() == one.bits());
  assert(signals == 1 && observed_flags == factor::fp::inexact);
  assert((one + one).bits() == UINT64_C(0x4000000000000000));
  assert(signals == 1); // Old sticky inexact cannot retrigger an exact addition.
  assert(factor::software_fp_flags == factor::fp::inexact);
  factor::software_fp_set_state(factor::fp::divide_by_zero << 8);
  assert((one / ieee_binary64::from_bits(0)).is_infinite());
  assert(signals == 2 && observed_flags == factor::fp::divide_by_zero);
  factor::software_fp_set_state(factor::fp::invalid << 8);
  factor::software_fp_raise_flags(factor::fp::invalid);
  assert(signals == 3 && observed_flags == factor::fp::invalid);
  uint32_t before = factor::software_fp_get_state();
  pthread_t thread;
  assert(pthread_create(&thread, nullptr, other_thread, nullptr) == 0);
  assert(pthread_join(thread, nullptr) == 0);
  assert(factor::software_fp_get_state() == before);
  assert(factor::software_fp_trap == trap);
  // A fresh inexact operation still traps when inexact was already sticky.
  factor::software_fp_set_state(factor::fp::inexact | (factor::fp::inexact << 8));
  assert((one + halfway).bits() == one.bits());
  assert(signals == 4);
  // Nested operations accumulate their flags; no outer destructor overwrites
  // them or restores flags explicitly cleared by a callback.
  factor::software_fp_trap = nested_trap;
  factor::software_fp_set_state(factor::fp::inexact << 8);
  assert((one + halfway).bits() == one.bits());
  assert(factor::software_fp_flags == (factor::fp::inexact | factor::fp::invalid));
  factor::software_fp_trap = clearing_trap;
  factor::software_fp_set_state(factor::fp::inexact << 8);
  assert((one + halfway).bits() == one.bits());
  assert(factor::software_fp_flags == 0);
  factor::software_fp_set_state(0);
  factor::software_fp_trap = nullptr;
  puts("software IEEE rounding, SIGFPE traps, sticky flags and TLS passed");
}
