// Run natively on ARMv7 Linux: g++ -std=c++17 arm32-callsite.cpp -o test && ./test
// Exercises the executable inline-target ABI, including Thumb interworking
// and rewriting a live call target after an instruction-cache flush.
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <sys/mman.h>
using cell = uintptr_t;
#define FACTOR_ASSERT assert
void flush_icache(cell start, cell size) {
  __builtin___clear_cache((char*)start, (char*)(start + size));
}
#include "../cpu-arm.32.hpp"
__attribute__((noinline)) static unsigned first(unsigned value) { return value + 37; }
__attribute__((noinline)) static unsigned second(unsigned value) { return value * 3; }
int main() {
  static_assert(sizeof(cell) == 4, "Execute this test on ARM32");
  int protection = PROT_READ | PROT_WRITE | PROT_EXEC;
#if defined(__NetBSD__)
  protection |= PROT_MPROTECT(PROT_EXEC);
#endif
  auto p = (uint32_t*)mmap(nullptr, 4096, protection,
                         MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  assert(p != MAP_FAILED);
  uint32_t code[] = {0xe92d4010, 0xe59fc004, 0xe12fff3c, 0xea000000,
                     (uint32_t)(cell)&first, 0xe8bd8010};
  memcpy(p, code, sizeof(code));
  flush_icache((cell)p, sizeof(code));
  cell ra = (cell)(p + 3);
  assert(factor::get_call_target(ra) == (void*)&first);
  assert(!factor::tail_call_site_p(ra));
  auto invoke = (unsigned (*)(unsigned))p;
  assert(invoke(5) == 42);
  factor::set_call_target(ra, (cell)&second);
  assert(factor::get_call_target(ra) == (void*)&second);
  assert(invoke(5) == 15);
  p[2] = 0xe12fff1c;
  assert(factor::tail_call_site_p(ra));
  assert(munmap(p, 4096) == 0);
  puts("ARM32 executable calls, interworking, patching and tail decoding pass");
}
