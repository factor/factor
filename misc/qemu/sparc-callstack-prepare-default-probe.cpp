/* Copyright (C) 2026 Doug Coleman. BSD license. */
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
extern "C" void factor_sparc_prepare_callstack(void*);
extern "C" uintptr_t factor_sparc_window_cookie;
int main() {
  sigset_t before, after;
  if (sigprocmask(SIG_SETMASK, nullptr, &before)) return 1;
  factor_sparc_prepare_callstack(reinterpret_cast<void*>(1));
  if (factor_sparc_window_cookie ||
      sigprocmask(SIG_SETMASK, nullptr, &after)) return 2;
  for (int signal = 1; signal < NSIG; ++signal)
    if (sigismember(&before, signal) != sigismember(&after, signal)) return 3;
  puts("PASS default callstack preparation leaves state unchanged");
}
