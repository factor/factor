// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
// Run with Alpha GCC and qemu-alpha, then on the full-system guest.
#include <cassert>
#include <cfenv>
#include <cmath>
#include <initializer_list>
#include <cstdint>
#include <cstring>
#include <cstdio>
#include <pthread.h>
#include <sys/mman.h>
namespace factor {
using cell = uintptr_t;
#define FACTOR_ASSERT(x) assert(x)
inline void flush_icache(cell, cell) {
  __asm__ __volatile__("mb; call_pal 0x86" ::: "memory");
}
}
#include "../cpu-alpha.hpp"
static volatile long value = 0;
static void* increment(void*) {
  for (unsigned i = 0; i < 10000; ++i) __sync_fetch_and_add(&value, 1);
  return nullptr;
}
static volatile long answer = 42;
extern "C" long first() { return answer; }
extern "C" long second() { return answer * 2; }
int main() {
  static_assert(sizeof(void*) == 8 && sizeof(long) == 8 && sizeof(double) == 8,
                "Alpha LP64 and IEEE double required");
  uint64_t bits;
  double one = 1.0;
  memcpy(&bits, &one, 8);
  assert(bits == UINT64_C(0x3ff0000000000000));
  auto* code = (uint32_t*)mmap(nullptr, 8192, PROT_READ | PROT_WRITE | PROT_EXEC,
                             MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  assert(code != MAP_FAILED);
  // Include both possible alignments of the embedded 64-bit literal.
  for (unsigned offset : {0U, 1U}) {
    uint32_t* p = code + offset + 3;
    uint32_t sequence[] = {0xc3600002, 0, 0, 0xa07b0004, 0xa37b0000,
                         0x4b61f63b, 0x48641723, 0x4763041b, 0x6b5b4000};
    p[-3] = 0x23deffe0; // lda sp,-32(sp)
    p[-2] = 0xb75e0008; // stq ra,8(sp)
    p[-1] = 0xb7be0010; // stq gp,16(sp)
    memcpy(p, sequence, sizeof(sequence));
    p[9] = 0xa7be0010; // ldq gp,16(sp)
    p[10] = 0xa75e0008; // ldq ra,8(sp)
    p[11] = 0x23de0020; // lda sp,32(sp)
    p[12] = 0x6bfa8001; // ret zero,(ra),1
    factor::cell end = (factor::cell)(p + 9);
    factor::set_call_target(end, (factor::cell)first);
    assert(factor::get_call_target(end) == (void*)first);
    assert(!factor::tail_call_site_p(end));
    assert(((long (*)())(p - 3))() == 42);
    factor::set_call_target(end, (factor::cell)second);
    assert(((long (*)())(p - 3))() == 84);
    p[8] = 0x6bfb4000;
    factor::flush_icache((factor::cell)p, sizeof(sequence));
    assert(factor::tail_call_site_p(end));
    assert(((long (*)())p)() == 84);
  }
  pthread_t threads[2];
  for (auto& thread : threads) assert(pthread_create(&thread, nullptr, increment, nullptr) == 0);
  for (auto& thread : threads) assert(pthread_join(thread, nullptr) == 0);
  assert(value == 20000);
  volatile double fraction = 1.5;
  assert(fesetround(FE_DOWNWARD) == 0 && nearbyint(fraction) == 1.0);
  assert(fesetround(FE_UPWARD) == 0 && nearbyint(fraction) == 2.0);
  assert(fesetround(FE_TONEAREST) == 0);
  assert(munmap(code, 8192) == 0);
  puts("Alpha native ABI, literal patching, tail calls, FP rounding and LL/SC probe passed");
}
