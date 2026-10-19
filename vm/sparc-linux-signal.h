/* Copyright (C) 2026 Doug Coleman. BSD license.
 * Linux native signal frames, not libc ucontext_t.
 * ABI sources: arch/sparc/kernel/{signal_32.c,signal32.c,signal_64.c}
 * and arch/sparc/include/asm/sigcontext.h in the Linux kernel.
 */
#ifndef FACTOR_SPARC_LINUX_SIGNAL_H
#define FACTOR_SPARC_LINUX_SIGNAL_H
#include <stdint.h>
#include <stddef.h>

#define FACTOR_SPARC_SIGNAL_STORAGE_SIZE 2048
/* The owner must preallocate one aligned slot per outstanding continuation.
 * No allocator, libc copy, or floating-point instruction is used here. */
struct factor_sparc_signal_storage {
  unsigned char bytes[FACTOR_SPARC_SIGNAL_STORAGE_SIZE] __attribute__((aligned(16)));
};
static inline void factor_sparc_signal_copy(void *dst, const void *src, size_t n) {
  volatile unsigned char *d = (volatile unsigned char *)dst;
  const volatile unsigned char *s = (const volatile unsigned char *)src;
  while (n--) *d++ = *s++;
}

/* Returns the physical cloned rt-frame address for sparc_rt_sigreturn.
 * raw is the third SA_SIGINFO argument. Copy before editing the live frame.
 * Preserve the native32 and compat32 layouts separately: compat32 carries
 * upper register halves and ASI in a V8+ extension before rwin_save. */
static inline uintptr_t factor_sparc_clone_signal(
    void *raw, struct factor_sparc_signal_storage *slot) {
#if __SIZEOF_POINTER__ == 8
  __asm__ volatile("flushw" ::: "memory");
#else
  __asm__ volatile("ta 3" ::: "memory");
#endif
  size_t prefix, fpu_offset, rwin_offset, fpu_size, rwin_size;
  unsigned char *source;
#if __SIZEOF_POINTER__ == 8
  source = (unsigned char *)raw - 192;
  prefix = 528; fpu_offset = 480; rwin_offset = 520;
  fpu_size = 280; rwin_size = 960;
#else
  int compat = (*(const uint32_t *)raw & 0xff000000u) == 0xff000000u;
  source = (unsigned char *)raw - 224;
  prefix = compat ? 416 : 344;
  fpu_offset = 312; rwin_offset = compat ? 408 : 340;
  fpu_size = compat ? 280 : 264;
  /* A compat kernel uses 64-bit register-window saves even for V8+ users. */
  rwin_size = compat ? 960 : 480;
#endif
  factor_sparc_signal_copy(slot->bytes, source, prefix);
  uintptr_t fpu = *(const uintptr_t *)(source + fpu_offset);
  uintptr_t rwin = *(const uintptr_t *)(source + rwin_offset);
  size_t tail = prefix;
  if (fpu) {
    factor_sparc_signal_copy(slot->bytes + tail, (void *)fpu, fpu_size);
    *(uintptr_t *)(slot->bytes + fpu_offset) = (uintptr_t)(slot->bytes + tail);
    tail += fpu_size;
  }
  if (rwin) {
    /* All tail records require native unsigned-long alignment. */
    tail = (tail + 7) & ~(size_t)7;
    factor_sparc_signal_copy(slot->bytes + tail, (void *)rwin, rwin_size);
    *(uintptr_t *)(slot->bytes + rwin_offset) = (uintptr_t)(slot->bytes + tail);
  }
  return (uintptr_t)slot->bytes;
}

/* The VM installs SA_ONSTACK, so this window is separate from the running
 * native signal handler. Call only after checking callstack guard space.
 * The generated entry must load cells 14/15 into i6/i7 before any SAVE or
 * window flush, otherwise the interrupted inputs overwrite the fake link.
 * Returns physical fake SP; raw saved SP is updated with the ABI bias. */
static inline uintptr_t factor_sparc_prepare_signal(
    void *raw, struct factor_sparc_signal_storage *slot, uintptr_t target) {
  uintptr_t clone = factor_sparc_clone_signal(raw, slot);
#if __SIZEOF_POINTER__ == 8
  uintptr_t *regs = (uintptr_t *)((unsigned char *)raw + 128);
  uintptr_t *pc = (uintptr_t *)((unsigned char *)raw + 264);
  const uintptr_t bias = 2047, frame = 192, payload = 176;
#else
  uintptr_t *regs = (uintptr_t *)((unsigned char *)raw + 16);
  uintptr_t *pc = (uintptr_t *)((unsigned char *)raw + 4);
  const uintptr_t bias = 0, frame = 112, payload = 96;
#endif
  uintptr_t old_sp = regs[14];
  /* Publish the captured interrupted window before replacing its SP. Later
   * window flushes operate on the synthetic frame; the caller-map walk must
   * also see the original frame's i6/i7. This native window area precedes all
   * Factor spills, and is separate from the SA_ONSTACK handler's window. */
  factor_sparc_signal_copy((void *)(old_sp + bias), slot->bytes,
                          16 * sizeof(uintptr_t));
  uintptr_t fake_sp = old_sp + bias - frame;
  factor_sparc_signal_copy((void *)fake_sp, slot->bytes, 16 * sizeof(uintptr_t));
  ((uintptr_t *)fake_sp)[14] = old_sp;
  ((uintptr_t *)fake_sp)[15] = pc[0] - 8;
  *(uintptr_t *)(fake_sp + payload) = clone;
  regs[14] = fake_sp - bias;
  pc[0] = target;
  pc[1] = target + 4;
  return fake_sp;
}

/* Mark/relocate every saved code continuation independently. The callback
 * receives the raw cell and its architectural +8 return-address bias. */
typedef void (*factor_sparc_signal_code_visitor)(void*, uintptr_t*, unsigned);
static inline void factor_sparc_visit_signal_code(
    struct factor_sparc_signal_storage* slot,
    factor_sparc_signal_code_visitor visit, void* data) {
#if __SIZEOF_POINTER__ == 8
  uintptr_t* regs = (uintptr_t*)(slot->bytes + 320);
  uintptr_t* pc = (uintptr_t*)(slot->bytes + 456);
  uintptr_t rwin = *(uintptr_t*)(slot->bytes + 520);
#else
  uintptr_t* regs = (uintptr_t*)(slot->bytes + 240);
  uintptr_t* pc = (uintptr_t*)(slot->bytes + 228);
  int compat = (*(uint32_t*)(slot->bytes + 224) & 0xff000000u) == 0xff000000u;
  uintptr_t rwin = *(uintptr_t*)(slot->bytes + (compat ? 408 : 340));
#endif
  visit(data, pc, 0);
  visit(data, pc + 1, 0);
  visit(data, (uintptr_t*)slot->bytes + 15, 8);
  visit(data, regs + 15, 8);
  if (rwin) {
    unsigned char* windows = (unsigned char*)rwin;
    int count = *(int*)windows;
    for (int i = 0; i < count && i < 7; ++i) {
#if __SIZEOF_POINTER__ == 8
      visit(data, (uintptr_t*)(windows + 8 + i * 128 + 120), 8);
#else
      if (compat) {
        uint64_t* raw = (uint64_t*)(windows + 8 + i * 128 + 120);
        uintptr_t value = (uintptr_t)*raw;
        visit(data, &value, 8);
        *raw = (*raw & 0xffffffff00000000ULL) | value;
      } else visit(data, (uintptr_t*)(windows + 4 + i * 64 + 60), 8);
#endif
    }
  }
}
#ifdef __cplusplus
extern "C" {
#endif
void sparc_rt_sigreturn(uintptr_t frame) __attribute__((noreturn));
#ifdef __cplusplus
}
#endif
#endif
