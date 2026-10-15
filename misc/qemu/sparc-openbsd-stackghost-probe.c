/* Copyright (C) 2026 Doug Coleman. BSD license. */
#include <stdint.h>
#include <stdio.h>
#ifdef FACTOR_SPARC_COOKIE_RUNTIME
#include <sys/wait.h>
#include <unistd.h>
#endif
#include "../../vm/sparc-openbsd-stackghost.h"
#ifdef __cplusplus
extern "C" void spill(void);
#else
extern void spill(void);
#endif
__asm__(".text\n.align 4\n.global spill\n.type spill,#function\n"
        "spill:\n save %sp, -176, %sp\n flushw\n ret\n restore\n"
        ".size spill,.-spill\n");
__attribute__((noinline)) static uintptr_t cookie(void) {
  uintptr_t sp, return_pc;
  __asm__ volatile("mov %%sp, %0\n\tmov %%i7, %1" : "=r"(sp), "=r"(return_pc));
  spill();
  uintptr_t encoded = ((volatile uintptr_t*)(sp + 2047))[15];
  uintptr_t process_cookie = encoded ^ return_pc;
  if (factor_sparc_decode_i7(encoded, process_cookie) != return_pc ||
      factor_sparc_decode_i7(return_pc, process_cookie) != return_pc ||
      factor_sparc_encode_i7(encoded, return_pc + 4, process_cookie) !=
          (encoded ^ return_pc ^ (return_pc + 4)) ||
      factor_sparc_encode_i7(return_pc, return_pc + 4, process_cookie) !=
          return_pc + 4)
    return 0;
  return process_cookie;
}
int main(void) {
  uintptr_t first = cookie(), second = cookie();
  if (!first || !(first & 3) || first != second) return 1;
#ifdef FACTOR_SPARC_COOKIE_RUNTIME
  if (first != factor_sparc_openbsd_window_cookie()) return 2;
  pid_t child = fork();
  if (child < 0) return 3;
  if (!child) _exit(cookie() != factor_sparc_openbsd_window_cookie());
  int status;
  if (waitpid(child, &status, 0) != child || !WIFEXITED(status) ||
      WEXITSTATUS(status)) return 4;
#endif
  puts("PASS native OpenBSD SPARC64 StackGhost saved i7 decode contract stable across calls");
  return 0;
}
