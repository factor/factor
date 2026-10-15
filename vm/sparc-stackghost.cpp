/* Copyright (C) 2026 Doug Coleman. BSD license. */
#include <stdint.h>
#if defined(__OpenBSD__) && defined(__sparc64__)
#include "master.hpp"
#endif
extern "C" {
/* Zero is the native ABI default; OpenBSD initializes its process cookie. */
uintptr_t factor_sparc_window_cookie;

/* Call before replacing the live window chain, while its links remain valid. */
void factor_sparc_prepare_callstack(void* vm) {
#if defined(__OpenBSD__) && defined(__sparc64__)
  auto* owner = static_cast<factor::factor_vm*>(vm);
  owner->abandon_sparc_signals(owner->ctx, 0);
#else
  (void)vm;
#endif
}
}
