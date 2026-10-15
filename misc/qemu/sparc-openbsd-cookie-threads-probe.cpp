/* Copyright (C) 2026 Doug Coleman. BSD license. */
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include "../../vm/sparc-openbsd-stackghost.h"
extern "C" void factor_sparc_openbsd_spill();
__attribute__((noinline)) static uintptr_t native_cookie() {
  uintptr_t sp, pc;
  __asm__ volatile("mov %%sp, %0\n\tmov %%i7, %1" : "=r"(sp), "=r"(pc));
  factor_sparc_openbsd_spill();
  return ((volatile uintptr_t*)(sp + 2047))[15] ^ pc;
}
struct result { unsigned mismatches; };
static void* verify(void* raw) {
  result* state = static_cast<result*>(raw);
  for (unsigned i = 0; i < 1000; ++i)
    if (native_cookie() != factor_sparc_window_cookie) ++state->mismatches;
  return nullptr;
}
int main() {
  pthread_t threads[4]; result results[4] = {};
  for (unsigned i = 0; i < 4; ++i)
    if (pthread_create(threads+i, nullptr, verify, results+i)) return 1;
  for (unsigned i = 0; i < 4; ++i)
    if (pthread_join(threads[i], nullptr) || results[i].mismatches) return 2;
  if (native_cookie() != factor_sparc_window_cookie) return 3;
  puts("PASS native StackGhost cookie shared by four pthreads (4000 independent spills)");
}
