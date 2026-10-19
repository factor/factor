// Native instruction relocation tests; these do not imply a Factor VM port.
#ifdef NDEBUG
#undef NDEBUG
#endif
#include <cassert>
#include <cstdint>
#include <cstring>
#include <random>
#include <sys/mman.h>
#define FACTOR_ASSERT(condition) assert(condition)
#include "../mips.hpp"
using namespace factor;

#if defined(__mips__)
static volatile uintptr_t native_value = 42;
__attribute__((noinline)) static uintptr_t native_target() {
  return native_value;
}
#endif

int main() {
  uint32_t li32[] = {0x3c020000, 0x34420000};
  uint32_t li64[] = {0x34020000, 0x00021438, 0x34420000,
                    0x00021438, 0x34420000, 0x00021438, 0x34420000};
  std::mt19937_64 random(42);
  for (unsigned i = 0; i < 10000; ++i) {
    uint64_t n = random();
    mips_store_li32(li32, uint32_t(n));
    assert(mips_load_li32(li32) == uint32_t(n));
    assert((li32[0] & 0xffff0000) == 0x3c020000);
    assert((li32[1] & 0xffff0000) == 0x34420000);
    mips_store_li64(li64, n);
    assert(mips_load_li64(li64) == n);
    assert(li64[1] == 0x00021438 && li64[3] == 0x00021438 && li64[5] == 0x00021438);
  }
  for (int32_t n = -131072; n <= 131068; n += 4) {
    uint32_t instruction = 0x10850000;
    mips_store_branch(&instruction, n);
    assert(mips_branch_displacement(instruction) == n);
    assert((instruction & 0xffff0000) == 0x10850000);
  }
#if defined(__mips__)
  uint32_t* code = (uint32_t*)mmap(nullptr, 4096, PROT_READ | PROT_WRITE,
      MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  assert(code != MAP_FAILED);
#if __SIZEOF_POINTER__ == 8
  memcpy(code, li64, sizeof(li64));
  const unsigned count = 7;
#else
  memcpy(code, li32, sizeof(li32));
  const unsigned count = 2;
#endif
  code[count] = 0x03e00008; // jr ra
  code[count + 1] = 0; // delay slot
  for (uint64_t n : {uint64_t(0), uint64_t(0x80000000), uint64_t(0xffffffff),
                      uint64_t(0x8000000000000000), UINT64_MAX}) {
    assert(mprotect(code, 4096, PROT_READ | PROT_WRITE) == 0);
#if __SIZEOF_POINTER__ == 8
    mips_store_li64(code, n);
#else
    mips_store_li32(code, uint32_t(n));
#endif
    __builtin___clear_cache((char*)code, (char*)(code + count + 2));
    assert(mprotect(code, 4096, PROT_READ | PROT_EXEC) == 0);
    assert(((uintptr_t (*)())code)() == uintptr_t(n));
  }
  // Tail-call native PIC code via t9; the callee derives its GP from t9.
  assert(mprotect(code, 4096, PROT_READ | PROT_WRITE) == 0);
#if __SIZEOF_POINTER__ == 8
  const uint32_t call[] = {0x34190000, 0x0019cc38, 0x37390000,
      0x0019cc38, 0x37390000, 0x0019cc38, 0x37390000, 0x03200008, 0};
  memcpy(code, call, sizeof(call));
  mips_store_li64(code, uintptr_t(&native_target));
#else
  const uint32_t call[] = {0x3c190000, 0x37390000, 0x03200008, 0};
  memcpy(code, call, sizeof(call));
  mips_store_li32(code, uintptr_t(&native_target));
#endif
  __builtin___clear_cache((char*)code, (char*)code + sizeof(call));
  assert(mprotect(code, 4096, PROT_READ | PROT_EXEC) == 0);
  assert(((uintptr_t (*)())code)() == 42);
  assert(munmap(code, 4096) == 0);
#endif
}
