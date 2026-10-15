/* Copyright (C) 2026 Doug Coleman. BSD license. */
#ifndef FACTOR_SPARC_OPENBSD_SIGNAL_H
#define FACTOR_SPARC_OPENBSD_SIGNAL_H
#include <setjmp.h>
#include "sparc-openbsd-signal-roots.h"

struct factor_sparc_signal_storage {
  /* The generated stub carries this opaque token, never a cloned context. */
  unsigned char bytes[1] __attribute__((aligned(16)));
  struct factor_sparc_openbsd_signal_roots roots;
  sigjmp_buf native;
  sigset_t resume_mask;
  stack_t original_stack;
  stack_t successor_stack;
  unsigned char* snapshot;
};
#ifdef __cplusplus
extern "C" {
#endif
void sparc_rt_sigreturn(uintptr_t) __attribute__((noreturn));
#ifdef __cplusplus
}
#endif
#endif
