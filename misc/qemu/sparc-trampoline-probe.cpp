#ifdef NDEBUG
#error This probe requires assertions enabled
#endif
// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
#include <cassert>
#include <cstdio>
#include <cstdint>
extern "C" long probe_restore_window();
extern "C" long probe_trampoline(void*,uintptr_t*,long,long);
extern "C" __attribute__((noinline)) long add(long x,long y) { asm volatile("mov 1, %%g2\nmov 2,%%g3\nmov 3,%%g4" ::: "g2","g3","g4"); return x+y; }
int main(){assert(probe_restore_window()==42);uintptr_t ctx[5]={}; assert(probe_trampoline((void*)add,ctx,19,23)==42); assert(ctx[0]); puts("SPARC native trampoline arguments, return, globals and published frame passed");}
