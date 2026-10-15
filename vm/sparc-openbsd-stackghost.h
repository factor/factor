/* Copyright (C) 2026 Doug Coleman. BSD license. */
#ifndef FACTOR_SPARC_OPENBSD_STACKGHOST_H
#define FACTOR_SPARC_OPENBSD_STACKGHOST_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
uintptr_t factor_sparc_openbsd_window_cookie(void);
extern uintptr_t factor_sparc_window_cookie;
#ifdef __cplusplus
}
#endif

/* Kernel spills encode i7; explicitly saved JIT links remain aligned. */
static inline uintptr_t factor_sparc_decode_i7(uintptr_t saved, uintptr_t cookie) {
  return (saved & 3) ? saved ^ cookie : saved;
}
static inline uintptr_t factor_sparc_encode_i7(
    uintptr_t original, uintptr_t address, uintptr_t cookie) {
  return (original & 3) ? address ^ cookie : address;
}
#endif
