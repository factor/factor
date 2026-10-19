// Copyright (C) 2026 Doug Coleman.
// Run with native PowerPC Linux GCC/QEMU for both widths and byte orders.
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <initializer_list>
namespace factor {
using cell = uintptr_t;
using fixnum = intptr_t;
#define FACTOR_ASSERT assert
#define VM_C_API extern "C"
static cell flushed_start, flushed_size;
extern "C" void flush_icache(cell start, cell size) {
  flushed_start = start;
  flushed_size = size;
  __builtin___clear_cache((char*)start, (char*)(start + size));
}
static void critical_error(const char*, cell) { std::abort(); }
enum { FP_TRAP_INVALID_OPERATION=1, FP_TRAP_OVERFLOW=2,
       FP_TRAP_UNDERFLOW=4, FP_TRAP_ZERO_DIVIDE=8, FP_TRAP_INEXACT=16 };
}
#if UINTPTR_MAX == UINT64_MAX
#define FACTOR_64
#endif
#include "../cpu-ppc.hpp"
int main() {
  using namespace factor;
  uint32_t branch = 0x48000001;
  cell ra = (cell)&branch + 4;
  for (fixnum offset : {fixnum(-33554432), fixnum(-4), fixnum(0), fixnum(33554428)}) {
    cell target = ra - 4 + offset;
    set_call_target(ra, target);
    assert((cell)get_call_target(ra) == target);
    assert((branch & 0xfc000003) == 0x48000001);
    assert(flushed_start == ra - 4 && flushed_size == 4);
  }
  assert(!tail_call_site_p(ra));
  branch &= ~uint32_t(1);
  assert(tail_call_site_p(ra));
#ifdef FACTOR_64
  uint32_t code[] = {0x3d800000, 0x618c0000, 0x798c07c6, 0x658c0000,
                     0x618c0000, 0x7d8903a6, 0x4e800421};
#else
  uint32_t code[] = {0x3d800000, 0x618c0000, 0x7d8903a6, 0x4e800421};
#endif
  ra = (cell)code + sizeof(code);
  assert(long_call_site_p(ra) && !tail_call_site_p(ra));
  for (cell target : {cell(0), cell(0x12345678), ~cell(0), ra + cell(0x4000000)}) {
    set_call_target(ra, target);
    assert((cell)get_call_target(ra) == target);
    assert(flushed_start == (cell)code && flushed_size == sizeof(code));
    assert(code[sizeof(code)/4 - 2] == 0x7d8903a6);
    assert(code[sizeof(code)/4 - 1] == 0x4e800421);
  }
  code[sizeof(code)/4 - 1] &= ~uint32_t(1);
  assert(long_call_site_p(ra) && tail_call_site_p(ra));
  code[sizeof(code)/4 - 2] = 0;
  assert(!long_call_site_p(ra));
  puts("PPC old/new call-site decode/patch >32MiB PASS");
}
