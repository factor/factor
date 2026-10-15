#include "../vm/sparc-linux-signal.h"
uintptr_t factor_sparc_prepare_signal_bridge(void *raw, void *slot, uintptr_t target) {
  return factor_sparc_prepare_signal(raw, (struct factor_sparc_signal_storage *)slot, target);
}
uint32_t factor_sparc_fpu_status(void *raw) {
  const unsigned char *context = (const unsigned char *)raw;
#if __SIZEOF_POINTER__ == 8
  uintptr_t state = *(const uintptr_t *)(context + 288);
  return state ? (uint32_t)*(const uint64_t *)(state + 256) : 0;
#else
  uintptr_t state = *(const uintptr_t *)(context + 88);
  if (!state) return 0;
  return (*(const uint32_t *)raw & 0xff000000u) == 0xff000000u
      ? (uint32_t)*(const uint64_t *)(state + 256)
      : *(const uint32_t *)(state + 256);
#endif
}
void factor_sparc_clear_fpu_status(void *raw) {
  unsigned char *context = (unsigned char *)raw;
#if __SIZEOF_POINTER__ == 8
  uintptr_t state = *(const uintptr_t *)(context + 288);
  if (state) *(uint64_t *)(state + 256) &= ~UINT64_C(0x1c3ff);
#else
  uintptr_t state = *(const uintptr_t *)(context + 88);
  if (!state) return;
  if ((*(const uint32_t *)raw & 0xff000000u) == 0xff000000u)
    *(uint64_t *)(state + 256) &= ~UINT64_C(0x1c3ff);
  else *(uint32_t *)(state + 256) &= ~UINT32_C(0x1c3ff);
#endif
}
void factor_sparc_visit_saved_code(void *saved, factor_sparc_signal_code_visitor visitor, void *opaque) {
  factor_sparc_visit_signal_code((struct factor_sparc_signal_storage *)saved, visitor, opaque);
}
#include <signal.h>
/* Zig's common Linux declaration omits SPARC64's reserved word before flags. */
struct factor_zig_sigaction {
  void (*handler)(int);
  sigset_t mask;
  unsigned flags;
  void (*restorer)(void);
};
int factor_sparc_sigaction_bridge(int sig, const struct factor_zig_sigaction *act,
                                 struct factor_zig_sigaction *old) {
  struct sigaction native, previous;
  if (act) {
    native.sa_handler = act->handler;
    native.sa_mask = act->mask;
    native.sa_flags = (int)act->flags;
    native.sa_restorer = act->restorer;
#if __SIZEOF_POINTER__ == 8
    native.__glibc_reserved0 = 0;
#endif
  }
  int result = sigaction(sig, act ? &native : 0, old ? &previous : 0);
  if (!result && old) {
    old->handler = previous.sa_handler;
    old->mask = previous.sa_mask;
    old->flags = (unsigned)previous.sa_flags;
    old->restorer = previous.sa_restorer;
  }
  return result;
}
