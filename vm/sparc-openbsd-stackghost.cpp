/* Copyright (C) 2026 Doug Coleman. BSD license. */
#include "sparc-openbsd-stackghost.h"
#include <stdlib.h>

extern "C" void factor_sparc_openbsd_spill();
__asm__(".text\n.align 4\n.global factor_sparc_openbsd_spill\n"
        ".type factor_sparc_openbsd_spill,#function\n"
        "factor_sparc_openbsd_spill:\n save %sp, -176, %sp\n"
        " flushw\n ret\n restore\n"
        ".size factor_sparc_openbsd_spill,.-factor_sparc_openbsd_spill\n");

__attribute__((noinline)) static uintptr_t capture_cookie() {
  uintptr_t sp, return_pc;
  __asm__ volatile("mov %%sp, %0\n\tmov %%i7, %1"
                   : "=r"(sp), "=r"(return_pc));
  factor_sparc_openbsd_spill();
  return ((volatile uintptr_t*)(sp + 2047))[15] ^ return_pc;
}
__attribute__((constructor)) static void initialize_cookie() {
  factor_sparc_window_cookie = capture_cookie();
  if (!(factor_sparc_window_cookie & 3) ||
      factor_sparc_window_cookie != capture_cookie()) abort();
}
extern "C" uintptr_t factor_sparc_openbsd_window_cookie() {
  return factor_sparc_window_cookie;
}
