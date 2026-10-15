/* Native NetBSD SPARC SA_SIGINFO context and setcontext probe. */
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ucontext.h>
#include <unistd.h>
#include "../../vm/sparc-netbsd-signal.h"

static struct factor_sparc_signal_storage storage;
static ucontext_t* saved;
static volatile sig_atomic_t handled, redirected;
static unsigned char altstack[65536];
static double original = 3.125, replacement = 8.5, actual;
static double original_top = 7.625, replacement_top = 9.125, actual_top;

static void continuation(void) {
  redirected = 1;
  __asm__ volatile("ldd %0, %%f0" :: "m"(replacement) : "f0", "f1");
  __asm__ volatile("ldd %0, %%f30" :: "m"(replacement_top) : "f30", "f31");
  factor_sparc_restore_signal_window((uintptr_t)saved);
#if __SIZEOF_POINTER__ == 4
  factor_sparc_restore_signal_fpu(saved);
#endif
  if (setcontext(saved)) _exit(91);
  _exit(92);
}

static void handler(int sig, siginfo_t *info, void *raw) {
  ucontext_t *uc = raw;
  uintptr_t local = (uintptr_t)&uc;
  if (sig != SIGUSR1 || !info || local < (uintptr_t)altstack ||
      local >= (uintptr_t)(altstack + sizeof(altstack))) _exit(93);
  if (uc->uc_mcontext.__gregs[_REG_nPC] !=
      uc->uc_mcontext.__gregs[_REG_PC] + 4) _exit(94);
  saved = (ucontext_t*)factor_sparc_clone_signal(uc, &storage);
  /* Kernel delivery must have already materialized its register windows. */
  if (saved->uc_mcontext.__gwins ||
      ((saved->uc_flags & _UC_FPU) && saved->uc_mcontext.__fpregs.__fpu_qcnt))
    _exit(95);
  handled = 1;
  _UC_MACHINE_SET_PC(uc, (uintptr_t)continuation);
}

static void relocate(void* opaque, uintptr_t* value, unsigned bias) {
  unsigned* count = opaque;
  *value += 0x1000;
  *count += 1;
  (void)bias;
}

static int clone_fixture(void) {
  ucontext_t uc;
  volatile __rwindow_t window;
  __gwindows_t windows;
  struct __fq queue;
  struct factor_sparc_signal_storage clone;
  unsigned count = 0;
  memset(&uc, 0, sizeof(uc));
  memset((void*)&window, 0, sizeof(window));
  memset(&windows, 0, sizeof(windows));
  memset(&queue, 0, sizeof(queue));
  uc.uc_flags = _UC_CPU | _UC_FPU;
#if __SIZEOF_POINTER__ == 8
  uc.uc_mcontext.__gregs[_REG_O6] = (uintptr_t)&window - 2047;
#else
  uc.uc_mcontext.__gregs[_REG_O6] = (uintptr_t)&window;
#endif
  uc.uc_mcontext.__gregs[_REG_PC] = 0x1000;
  uc.uc_mcontext.__gregs[_REG_nPC] = 0x2000;
  uc.uc_mcontext.__gregs[_REG_O7] = 0x3000;
  window.__rw_in[7] = 0x4000;
  windows.__wbcnt = 1;
  windows.__wbuf[0].__rw_in[7] = 0x5000;
  uc.uc_mcontext.__gwins = &windows;
  uc.uc_mcontext.__fpregs.__fpu_q = &queue;
  uc.uc_mcontext.__fpregs.__fpu_qcnt = 1;
  ucontext_t* copy = (ucontext_t*)factor_sparc_clone_signal(&uc, &clone);
  if (copy->uc_mcontext.__fpregs.__fpu_q == &queue) return 3;
#if __SIZEOF_POINTER__ == 8
  if (copy->uc_mcontext.__gwins == &windows) return 3;
#endif
  factor_sparc_visit_signal_code(&clone, relocate, &count);
  factor_sparc_restore_signal_window((uintptr_t)copy);
#if __SIZEOF_POINTER__ == 8
  if (count != 5 || copy->uc_mcontext.__gwins->__wbuf[0].__rw_in[7] != 0x6000) return 4;
#else
  if (count != 4 || copy->uc_mcontext.__gwins) return 4;
#endif
  return copy->uc_mcontext.__gregs[_REG_PC] != 0x2000 ||
      copy->uc_mcontext.__gregs[_REG_nPC] != 0x3000 ||
      copy->uc_mcontext.__gregs[_REG_O7] != 0x4000 ||
      window.__rw_in[7] != 0x5000;
}

int main(void) {
  int fixture = clone_fixture();
  if (fixture) return fixture;
  stack_t ss = { .ss_sp = altstack, .ss_size = sizeof(altstack) };
  struct sigaction sa;
  memset(&sa, 0, sizeof(sa));
  sa.sa_sigaction = handler;
  sa.sa_flags = SA_SIGINFO | SA_ONSTACK;
  sigemptyset(&sa.sa_mask);
  if (sigaltstack(&ss, 0) || sigaction(SIGUSR1, &sa, 0)) return 1;
  __asm__ volatile("ldd %0, %%f0" :: "m"(original) : "f0", "f1");
  __asm__ volatile("ldd %0, %%f30" :: "m"(original_top) : "f30", "f31");
  if (raise(SIGUSR1) || !handled || !redirected) return 2;
  __asm__ volatile("std %%f0, %0" : "=m"(actual));
  __asm__ volatile("std %%f30, %0" : "=m"(actual_top));
  if (actual != original || actual_top != original_top) return 6;
  printf("PASS native NetBSD SPARC%zu SA_SIGINFO altstack PC/NPC setcontext FP restore; ucontext=%zu FSR=%zu\n",
         sizeof(void*) * 8, sizeof(ucontext_t),
         sizeof(saved->uc_mcontext.__fpregs.__fpu_fsr));
  return 0;
}
