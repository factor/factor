// RV32GC and RV64GC relocation formats are tested on every host architecture.
#ifdef NDEBUG
#undef NDEBUG
#endif
#include <cassert>
#include <cstdint>
#include <limits>
#include <random>
#if defined(__riscv)
#include <sys/mman.h>
#include <sys/cachectl.h>
#endif
#define FACTOR_ASSERT(condition) assert(condition)
#include "../riscv.hpp"
using namespace factor;

#if defined(__riscv)
static void test_executable_relocations() {
  uint32_t* code = (uint32_t*)mmap(NULL, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
                                 MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  assert(code != MAP_FAILED);
#if __riscv_xlen == 32
  code[0] = 0x537; // LUI a0
  code[1] = 0x50513; // ADDI a0,a0
  code[2] = 0x8067; // RET
  for (uint32_t value : {uint32_t(0), uint32_t(2048), uint32_t(0x7ffff800),
                        uint32_t(0x80000000), UINT32_MAX}) {
    riscv_store_li32(code, value);
    assert(__riscv_flush_icache(code, code + 3, 0) == 0);
    assert(((uint32_t (*)())code)() == value);
  }
#else
  const uint32_t skeleton[] = {0x537, 0x50513, 0xc51513, 0x50513,
                              0xc51513, 0x50513, 0xc51513, 0x50513, 0x8067};
  for (unsigned i = 0; i < 9; ++i) code[i] = skeleton[i];
  for (uint64_t value : {uint64_t(0), uint64_t(2048), uint64_t(INT64_MAX),
                        uint64_t(INT64_MIN), UINT64_MAX}) {
    riscv_store_li(code, value);
    assert(__riscv_flush_icache(code, code + 9, 0) == 0);
    assert(((uint64_t (*)())code)() == value);
  }
#endif
  // Execute forward and backward AUIPC/JALR jumps. The RET uses
  // the caller's RA because the generated jump writes x0, not RA.
  code[0] = 0x00100513; // ADDI a0,x0,1
  code[1] = 0x8067;
  code[2] = 0x00200513;
  code[3] = 0x8067;
  code[4] = 0x297; // AUIPC t0
  code[5] = 0x28067; // JALR x0,t0
  for (unsigned destination : {0u, 2u}) {
#if __riscv_xlen == 32
    riscv_store_pair32(code + 4, uint32_t((destination - 4) * 4));
#else
    riscv_store_pair(code + 4, (int64_t(destination) - 4) * 4);
#endif
    assert(__riscv_flush_icache(code, code + 6, 0) == 0);
    assert(((uintptr_t (*)())(code + 4))() == destination / 2 + 1);
  }
  code[6] = 0x00300513;
  code[7] = 0x8067;
#if __riscv_xlen == 32
  riscv_store_pair32(code + 4, 8);
#else
  riscv_store_pair(code + 4, 8);
#endif
  assert(__riscv_flush_icache(code, code + 8, 0) == 0);
  assert(((uintptr_t (*)())(code + 4))() == 3);
  assert(munmap(code, 4096) == 0);
}
#endif

int main() {
#if defined(__riscv)
  test_executable_relocations();
#endif
  for (int64_t delta : {int64_t(INT32_MIN), int64_t(-1048576), int64_t(-4096),
       int64_t(-2049), int64_t(-2048), int64_t(-1), int64_t(0), int64_t(2047),
       int64_t(2048), int64_t(4095), int64_t(INT32_MAX - 2048)}) {
    uint32_t pair[] = {0x297, 0x280e7};
    riscv_store_pair(pair, delta);
    assert(riscv_pair_displacement(pair) == delta);
    assert((pair[0] & 0xfff) == 0x297);
    assert((pair[1] & 0xfffff) == 0x280e7);
  }
  for (int64_t n = -4096; n < 4096; n += 2)
    assert(riscv_branch_displacement(riscv_branch_bits(n) | 0xb5063) == n);
  for (int64_t n = -1048576; n < 1048576; n += 2)
    assert(riscv_jal_displacement(riscv_jal_bits(n) | 0xef) == n);

  const uint32_t skeleton[] = {
    0x537, 0x50513, 0xc51513, 0x50513,
    0xc51513, 0x50513, 0xc51513, 0x50513
  };
  auto check_literal = [&](uint64_t value) {
    uint32_t code[8];
    for (unsigned i = 0; i < 8; ++i) code[i] = skeleton[i];
    riscv_store_li(code, value);
    assert(riscv_load_li(code) == value);
    assert((code[0] & 0xfff) == skeleton[0]);
    for (unsigned i = 1; i < 8; ++i)
      assert((code[i] & 0xfffff) == (skeleton[i] & 0xfffff));
  };
  for (uint64_t v : {uint64_t(0), uint64_t(1), UINT64_MAX, uint64_t(INT64_MAX),
       uint64_t(INT64_MIN), uint64_t(2047), uint64_t(2048), uint64_t(-2048),
       uint64_t(-2049), uint64_t(0x123456789abcdef0)}) check_literal(v);
  auto check_literal32 = [&](uint32_t value) {
    uint32_t code[] = {0x537, 0x50513, 0xdeadbeef, 0x01234567};
    riscv_store_li32(code, value);
    assert(riscv_load_li32(code) == value);
    assert((code[0] & 0xfff) == 0x537);
    assert((code[1] & 0xfffff) == 0x50513);
    assert(code[2] == 0xdeadbeef && code[3] == 0x01234567);

    uint32_t pair[] = {0x297, 0x280e7};
    riscv_store_pair32(pair, value);
    assert(uint32_t(riscv_pair_displacement(pair)) == value);
    assert((pair[0] & 0xfff) == 0x297);
    assert((pair[1] & 0xfffff) == 0x280e7);
  };
  for (uint32_t v : {uint32_t(0), uint32_t(1), UINT32_MAX,
       uint32_t(INT32_MAX), uint32_t(INT32_MIN), uint32_t(2047),
       uint32_t(2048), uint32_t(-2048), uint32_t(-2049),
       uint32_t(0x7ffff7ff), uint32_t(0x7ffff800), uint32_t(0x800007ff),
       uint32_t(0x89abcdef)}) check_literal32(v);
  std::mt19937_64 random(0x52563634);
  for (unsigned i = 0; i < 100000; ++i) {
    check_literal(random());
    check_literal32(uint32_t(random()));
  }
}
