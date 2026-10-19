/* Copyright (C) 2026 Doug Coleman. BSD license. */
#ifndef FACTOR_SPARC_OPENBSD_CONTEXT_H
#define FACTOR_SPARC_OPENBSD_CONTEXT_H
#include <stdint.h>
#include <machine/frame.h>
#include <machine/fsr.h>

/* OpenBSD sigcode has a SAVE frame containing globals and FP state.
 * Spill it before accessing locals that its trusted return will reload. */
static inline uintptr_t* factor_sparc_openbsd_signal_window(void* context) {
  __asm__ volatile("flushw" ::: "memory");
  return (uintptr_t*)((unsigned char*)context - 144 - CC64FSZ - 320);
}
static inline uint64_t* factor_sparc_openbsd_saved_fsr(void* context) {
  uintptr_t* window = factor_sparc_openbsd_signal_window(context);
  return (window[0] & FPRS_DL)
      ? (uint64_t*)((unsigned char*)window + CC64FSZ) : 0;
}
static inline unsigned factor_sparc_openbsd_fpu_status(void* context) {
  uint64_t* fsr = factor_sparc_openbsd_saved_fsr(context);
  return fsr ? (unsigned)*fsr : 0;
}
static inline void factor_sparc_openbsd_clear_fpu_status(void* context) {
  uint64_t* fsr = factor_sparc_openbsd_saved_fsr(context);
  if (fsr) *fsr &= ~UINT64_C(0x3ff);
}
#endif
