/* Copyright (C) 2026 Doug Coleman. BSD license. */
#ifndef FACTOR_SPARC_OPENBSD_SIGNAL_ROOTS_H
#define FACTOR_SPARC_OPENBSD_SIGNAL_ROOTS_H
#include <signal.h>
#include "sparc-openbsd-context.h"
#include "sparc-openbsd-stackghost.h"

/* The authenticated context stays at its original address until sigcode
 * returns. Keep its interrupted window separately from the handler window. */
struct factor_sparc_openbsd_signal_roots {
  struct sigcontext* original;
  uintptr_t interrupted_window[16];
};
static inline void factor_sparc_openbsd_capture_signal_roots(
    struct factor_sparc_openbsd_signal_roots* roots, void* raw) {
  roots->original = (struct sigcontext*)raw;
  factor_sparc_openbsd_signal_window(raw);
  const volatile uintptr_t* window = (const volatile uintptr_t*)
      ((uintptr_t)roots->original->sc_sp + 2047);
  for (unsigned i = 0; i < 16; ++i) roots->interrupted_window[i] = window[i];
}
static inline void factor_sparc_openbsd_restore_signal_roots(
    const struct factor_sparc_openbsd_signal_roots* roots) {
  volatile uintptr_t* window = (volatile uintptr_t*)
      ((uintptr_t)roots->original->sc_sp + 2047);
  for (unsigned i = 0; i < 16; ++i) window[i] = roots->interrupted_window[i];
}
typedef void (*factor_sparc_openbsd_code_visitor)(void*, uintptr_t*, unsigned);
static inline void factor_sparc_openbsd_visit_i7(
    uintptr_t* slot, uintptr_t cookie,
    factor_sparc_openbsd_code_visitor visit, void* data) {
  uintptr_t original = *slot;
  uintptr_t decoded = factor_sparc_decode_i7(original, cookie);
  visit(data, &decoded, 8);
  *slot = factor_sparc_encode_i7(original, decoded, cookie);
}
static inline void factor_sparc_openbsd_visit_signal_code(
    struct factor_sparc_openbsd_signal_roots* roots, uintptr_t cookie,
    factor_sparc_openbsd_code_visitor visit, void* data) {
  struct sigcontext* sc = roots->original;
  visit(data, (uintptr_t*)&sc->sc_pc, 0);
  visit(data, (uintptr_t*)&sc->sc_npc, 0);
  /* sigcode's SAVE preserves the interrupted o7 as its own i7. */
  factor_sparc_openbsd_visit_i7(
      factor_sparc_openbsd_signal_window(sc) + 15, cookie, visit, data);
  factor_sparc_openbsd_visit_i7(
      roots->interrupted_window + 15, cookie, visit, data);
}
#endif
