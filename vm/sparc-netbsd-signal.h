/* Copyright (C) 2026 Doug Coleman. BSD license. */
#ifndef FACTOR_SPARC_NETBSD_SIGNAL_H
#define FACTOR_SPARC_NETBSD_SIGNAL_H
#include <stdint.h>
#include <stddef.h>
#include <ucontext.h>

/* Keep every pointer-bearing record independent of the live altstack. */
struct factor_sparc_signal_storage {
  __rwindow_t interrupted_window;
  unsigned char bytes[sizeof(ucontext_t) + sizeof(__gwindows_t) +
                      256 * sizeof(struct __fq) + 16] __attribute__((aligned(16)));
};
static inline void factor_sparc_signal_copy(void* dst, const void* src, size_t n) {
  volatile unsigned char* d = (volatile unsigned char*)dst;
  const volatile unsigned char* s = (const volatile unsigned char*)src;
  while (n--) *d++ = *s++;
}

#if __SIZEOF_POINTER__ == 4
static inline void factor_sparc_capture_signal_fpu(ucontext_t* uc) {
  /* NetBSD V8 does not export FP state through cpu_getmcontext. Capture
   * live registers before entering the generated Factor signal handler. */
  __asm__ volatile(
      "std %%f0, [%0 + 0]\n\t"
      "std %%f2, [%0 + 8]\n\t"
      "std %%f4, [%0 + 16]\n\t"
      "std %%f6, [%0 + 24]\n\t"
      "std %%f8, [%0 + 32]\n\t"
      "std %%f10, [%0 + 40]\n\t"
      "std %%f12, [%0 + 48]\n\t"
      "std %%f14, [%0 + 56]\n\t"
      "std %%f16, [%0 + 64]\n\t"
      "std %%f18, [%0 + 72]\n\t"
      "std %%f20, [%0 + 80]\n\t"
      "std %%f22, [%0 + 88]\n\t"
      "std %%f24, [%0 + 96]\n\t"
      "std %%f26, [%0 + 104]\n\t"
      "std %%f28, [%0 + 112]\n\t"
      "std %%f30, [%0 + 120]\n\t"
      : : "r"(uc->uc_mcontext.__fpregs.__fpu_fr.__fpu_regs) : "memory");
  __asm__ volatile("st %%fsr, %0"
      : "=m"(uc->uc_mcontext.__fpregs.__fpu_fsr));
  uc->uc_mcontext.__fpregs.__fpu_q = NULL;
  uc->uc_mcontext.__fpregs.__fpu_qcnt = 0;
}
static inline void factor_sparc_restore_signal_fpu(ucontext_t* uc) {
  __asm__ volatile(
      "ldd [%0 + 0], %%f0\n\t"
      "ldd [%0 + 8], %%f2\n\t"
      "ldd [%0 + 16], %%f4\n\t"
      "ldd [%0 + 24], %%f6\n\t"
      "ldd [%0 + 32], %%f8\n\t"
      "ldd [%0 + 40], %%f10\n\t"
      "ldd [%0 + 48], %%f12\n\t"
      "ldd [%0 + 56], %%f14\n\t"
      "ldd [%0 + 64], %%f16\n\t"
      "ldd [%0 + 72], %%f18\n\t"
      "ldd [%0 + 80], %%f20\n\t"
      "ldd [%0 + 88], %%f22\n\t"
      "ldd [%0 + 96], %%f24\n\t"
      "ldd [%0 + 104], %%f26\n\t"
      "ldd [%0 + 112], %%f28\n\t"
      "ldd [%0 + 120], %%f30\n\t"
      : : "r"(uc->uc_mcontext.__fpregs.__fpu_fr.__fpu_regs)
      : "f0", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12", "f13", "f14", "f15", "f16", "f17", "f18", "f19", "f20", "f21", "f22", "f23", "f24", "f25", "f26", "f27", "f28", "f29", "f30", "f31", "memory");
  __asm__ volatile("ld %0, %%fsr"
      : : "m"(uc->uc_mcontext.__fpregs.__fpu_fsr));
}
#endif
static inline uintptr_t factor_sparc_clone_signal(
    void* raw, struct factor_sparc_signal_storage* slot) {
  ucontext_t* saved = (ucontext_t*)slot->bytes;
  factor_sparc_signal_copy(saved, raw, sizeof(*saved));
  factor_sparc_signal_copy(&slot->interrupted_window,
                          (void*)_UC_MACHINE_SP(saved),
                          sizeof(slot->interrupted_window));
  unsigned char* tail = slot->bytes + sizeof(*saved);
  // NetBSD V8 cpu_getmcontext leaves this unsupported member undefined.
#if __SIZEOF_POINTER__ == 4
  saved->uc_mcontext.__gwins = NULL;
  if (!(saved->uc_flags & _UC_FPU)) factor_sparc_capture_signal_fpu(saved);
#endif
  if (saved->uc_mcontext.__gwins) {
    factor_sparc_signal_copy(tail, saved->uc_mcontext.__gwins, sizeof(__gwindows_t));
    saved->uc_mcontext.__gwins = (__gwindows_t*)tail;
    tail += sizeof(__gwindows_t);
  }
  if ((saved->uc_flags & _UC_FPU) && saved->uc_mcontext.__fpregs.__fpu_qcnt) {
    size_t bytes = saved->uc_mcontext.__fpregs.__fpu_qcnt * sizeof(struct __fq);
    factor_sparc_signal_copy(tail, saved->uc_mcontext.__fpregs.__fpu_q, bytes);
    saved->uc_mcontext.__fpregs.__fpu_q = (struct __fq*)tail;
  }
  return (uintptr_t)saved;
}
static inline uintptr_t factor_sparc_prepare_signal(
    void* raw, struct factor_sparc_signal_storage* slot, uintptr_t target) {
  uintptr_t clone = factor_sparc_clone_signal(raw, slot);
  ucontext_t* uc = (ucontext_t*)raw;
#if __SIZEOF_POINTER__ == 8
  const uintptr_t bias = 2047, frame = 192, payload = 176;
#else
  const uintptr_t bias = 0, frame = 112, payload = 96;
#endif
  uintptr_t old_sp = uc->uc_mcontext.__gregs[_REG_O6];
  uintptr_t fake_sp = old_sp + bias - frame;
  factor_sparc_signal_copy((void*)fake_sp, &slot->interrupted_window,
                          16 * sizeof(uintptr_t));
  ((uintptr_t*)fake_sp)[14] = old_sp;
  ((uintptr_t*)fake_sp)[15] = uc->uc_mcontext.__gregs[_REG_PC] - 8;
  *(uintptr_t*)(fake_sp + payload) = clone;
  uc->uc_mcontext.__gregs[_REG_O6] = fake_sp - bias;
  _UC_MACHINE_SET_PC(uc, target);
  return fake_sp;
}
typedef void (*factor_sparc_signal_code_visitor)(void*, uintptr_t*, unsigned);
static inline void factor_sparc_visit_signal_code(
    struct factor_sparc_signal_storage* slot,
    factor_sparc_signal_code_visitor visit, void* data) {
  ucontext_t* uc = (ucontext_t*)slot->bytes;
  visit(data, (uintptr_t*)&uc->uc_mcontext.__gregs[_REG_PC], 0);
  visit(data, (uintptr_t*)&uc->uc_mcontext.__gregs[_REG_nPC], 0);
  visit(data, (uintptr_t*)&uc->uc_mcontext.__gregs[_REG_O7], 8);
  visit(data, (uintptr_t*)&slot->interrupted_window.__rw_in[7], 8);
  __gwindows_t* windows = uc->uc_mcontext.__gwins;
  if (windows)
    for (int i = 0; i < windows->__wbcnt && i < _SPARC_MAXREGWINDOW; ++i)
      visit(data, (uintptr_t*)&windows->__wbuf[i].__rw_in[7], 8);
}
static inline void factor_sparc_restore_signal_window(uintptr_t frame) {
  struct factor_sparc_signal_storage* slot =
      (struct factor_sparc_signal_storage*)(frame -
        offsetof(struct factor_sparc_signal_storage, bytes));
  factor_sparc_signal_copy((void*)_UC_MACHINE_SP((ucontext_t*)frame),
                          &slot->interrupted_window,
                          sizeof(slot->interrupted_window));
}
#ifdef __cplusplus
extern "C" {
#endif
void sparc_rt_sigreturn(uintptr_t frame) __attribute__((noreturn));
#ifdef __cplusplus
}
#endif
#endif
