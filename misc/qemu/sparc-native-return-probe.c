/* Copyright (C) 2026 Doug Coleman. BSD license. */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include "sparc-native-return-data.h"
extern uintptr_t factor_sparc_window_cookie;
extern void factor_sparc_openbsd_spill(void), trampoline(void);
struct pair { uintptr_t first, second; };
extern struct pair run_native_return(void*, void*, double*);
static void* expected_vm;
static struct pair native_result(void* vm) {
  factor_sparc_openbsd_spill();
  double floating = 3.25;
  __asm__ volatile("ldd [%0], %%f0" : : "r"(&floating) : "f0", "f1");
  struct pair result = {vm == expected_vm ? 43 : 0, 44};
  return result;
}
static uint32_t readword(unsigned char* p) {
  return (uint32_t)p[0] << 24 | (uint32_t)p[1] << 16 | p[2] << 8 | p[3];
}
static void writeword(unsigned char* p, uint32_t n) {
  p[0] = n >> 24; p[1] = n >> 16; p[2] = n >> 8; p[3] = n;
}
static void set32(unsigned char* p, uint32_t n) {
  writeword(p, (readword(p) & ~0x3fffff) | (n >> 10));
  writeword(p + 4, (readword(p + 4) & ~0x3ff) | (n & 0x3ff));
}
static void patch(unsigned char* end, uintptr_t n) {
  set32(end - 24, (uint64_t)n >> 32); set32(end - 12, n);
}
int main(void) {
  unsigned char* code = mmap(0, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
                            MAP_PRIVATE | MAP_ANON, -1, 0);
  if (code == MAP_FAILED) return 1;
  memcpy(code, gate_code, sizeof gate_code);
  unsigned native = 0;
  for (unsigned i = 0; i < sizeof gate_rel / sizeof gate_rel[0]; ++i) {
    unsigned record = gate_rel[i], type = record >> 28;
    uintptr_t target;
    if (type == 12) target = (uintptr_t)trampoline;
    else if (type == 0)
      target = native++ ? (uintptr_t)&factor_sparc_window_cookie
                        : (uintptr_t)native_result;
    else return 2;
    patch(code + gate_prefix + (record & 0xffffff), target);
  }
  if (native != 2) return 4;
  __builtin___clear_cache((char*)code, (char*)code + sizeof gate_code);
  uintptr_t ds[2] = {0}, rs[2] = {0}, context[5] = {0};
  void* vm[1] = {context};
  context[2] = (uintptr_t)ds; context[3] = (uintptr_t)rs;
  expected_vm = vm;
  double floating = 0;
  struct pair result = run_native_return(vm, code, &floating);
  printf("pair=%lu,%lu floating=%g\n", (unsigned long)result.first,
         (unsigned long)result.second, floating);
  if (result.first != 43 || result.second != 44 || floating != 3.25)
    return 3;
  puts("PASS emitted native primitive return preserves pair, FPU and VM globals");
}
