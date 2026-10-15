/* Copyright (C) 2026 Doug Coleman. BSD license. */
#include <stdint.h>
#include <stdio.h>
#include "../../vm/sparc-openbsd-stackghost.h"

extern void factor_sparc_openbsd_spill(void);
extern void sparc_restore_window(uintptr_t frame, void (*continuation)(void));
extern void continuation(void);
struct pair { long first, second; };
struct native_context { uintptr_t top; };
extern void trampoline(void);
extern struct pair invoke_trampoline(struct native_context*, void*, void*);
__asm__(".text\n.align 4\n.global continuation\n"
        ".type continuation,#function\n"
        "continuation:\n mov 42, %i0\n ret\n restore\n"
        ".size continuation,.-continuation\n"
        ".global invoke_trampoline\n.type invoke_trampoline,#function\n"
        "invoke_trampoline:\n save %sp, -176, %sp\n"
        " mov %g2, %l0\n mov %g3, %l1\n mov %g4, %l2\n mov %g5, %l3\n"
        " mov %i0, %g5\n mov %i1, %g1\n mov 42, %o0\n"
        " jmpl %i2, %o7\n nop\n mov %o0, %i0\n mov %o1, %i1\n"
        " mov %l0, %g2\n mov %l1, %g3\n mov %l2, %g4\n mov %l3, %g5\n"
        " ret\n restore\n.size invoke_trampoline,.-invoke_trampoline\n");
__attribute__((noinline)) static struct pair native_result(long value) {
  factor_sparc_openbsd_spill();
  struct pair result = {value + 1, value + 2};
  return result;
}
__attribute__((noinline)) static long restore_frame(int mode) {
  uintptr_t sp, raw;
  __asm__ volatile("mov %%sp, %0\n\tmov %%i7, %1" : "=r"(sp), "=r"(raw));
  factor_sparc_openbsd_spill();
  uintptr_t* frame = (uintptr_t*)(sp + 2047);
  if (!(frame[15] & 3) ||
      factor_sparc_decode_i7(frame[15], factor_sparc_window_cookie) != raw)
    return -1;
  void (*target)(void) = continuation;
  if (mode == 1)
    target = (void (*)(void))
        ((((uintptr_t)continuation - 8) ^ factor_sparc_window_cookie) + 8);
  if (mode == 2) frame[15] = raw;
  sparc_restore_window((uintptr_t)frame, target);
  return -2;
}
int main(void) {
  if (restore_frame(0) != 42) return 1;
  if (restore_frame(1) != 42) return 1;
  if (restore_frame(2) != 42) return 1;
  struct native_context context = {0};
  struct pair result = invoke_trampoline(&context, (void*)native_result,
                                        (void*)trampoline);
  if (result.first != 43 || result.second != 44 || !context.top ||
      (context.top & 15)) return 2;
  puts("PASS native OpenBSD SPARC64 mixed window/continuation restore and native pair return");
  return 0;
}
