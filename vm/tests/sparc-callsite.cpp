// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
// Build with GNU/Linux SPARC GCC -m32/-m64 -mcpu=v9; run its matching ABI.
// Calls real C targets through SET32/SET64 + JMPL-o7, then patches executable
// code through the actual C++ VM helper and checks tail classification.
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <sys/mman.h>
namespace factor {
using cell = uintptr_t;
using fixnum = intptr_t;
#define FACTOR_ASSERT assert
void flush_icache(cell start, cell size) {
  for (cell offset = 0; offset < size; offset += 8)
    __asm__ volatile("flush %0" : : "r"(start + offset) : "memory");
}
}
#if UINTPTR_MAX == UINT64_MAX
#define FACTOR_64
#endif
#include "../sparc.hpp"
#include "../cpu-sparc.hpp"
__attribute__((noinline)) static unsigned first(unsigned value) { return value + 37; }
__attribute__((noinline)) static unsigned second(unsigned value) { return value * 3; }
int main() {
  using namespace factor;
  auto p = static_cast<uint8_t*>(mmap(nullptr, 4096,
      PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0));
  assert(p != MAP_FAILED);
  unsigned offset = 0;
  auto emit = [&](uint32_t instruction) {
    sparc_store_instruction(p + offset, instruction); offset += 4;
  };
  emit(0x9de3a000u | ((-JIT_FRAME_SIZE) & 0x1fff)); // SAVE ABI frame
  emit(0x90100018); // i0 -> o0
  auto literal = p + offset;
  if (sizeof(cell) == 8) {
    const uint32_t scratch = 23;
    emit(0x01000000 | (scratch << 25));
    emit(0x80102000 | (scratch << 25) | (scratch << 14));
    emit(0x81283020 | (scratch << 25) | (scratch << 14));
    emit(0x03000000); emit(0x82106000); emit(0x82104000 | scratch);
    sparc_store_set64(literal, (cell)&first);
  } else {
    emit(0x03000000); emit(0x82106000);
    sparc_store_set32(literal, (cell)&first);
  }
  auto call = p + offset;
  emit(0x9fc06000); emit(0x01000000); // JMPL g1,o7; delay NOP
  const cell return_address = (cell)(p + offset);
  emit(0xb0100008); // o0 -> i0
  emit(0x81c7e008); emit(0x81e80000); // RET; RESTORE
  flush_icache((cell)p, offset);
  auto invoke = reinterpret_cast<unsigned(*)(unsigned)>(p);
  assert(get_call_target(return_address) == (void*)&first);
  assert(!tail_call_site_p(return_address));
  for (unsigned i = 0; i < 1003; ++i) {
    set_call_target(return_address, (cell)&first);
    assert(invoke(i) == i + 37);
    set_call_target(return_address, (cell)&second);
    assert(get_call_target(return_address) == (void*)&second);
    assert(invoke(i) == i * 3);
  }
  sparc_store_instruction(call, 0x81c06000); // JMPL g1,g0 tail encoding
  assert(tail_call_site_p(return_address));
  assert(get_call_target(return_address) == (void*)&second);
  assert(munmap(p, 4096) == 0);
  puts("PASS SPARC C++ executable optimized JMPL-o7 call patching 2006 calls and tail classification");
}
