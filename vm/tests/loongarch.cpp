#ifdef NDEBUG
#undef NDEBUG
#endif
#include <cassert>
#include <cstdint>
#include <initializer_list>
#include <random>
#if defined(__loongarch64)
#include <sys/mman.h>
#endif
#define FACTOR_ASSERT assert
#include "../loongarch.hpp"
int main() {
  uint32_t literal[9] = {0x14000004,0x02c00084,0x00413084,0x02c00084,
    0x00413084,0x02c00084,0x00413084,0x02c00084,0x4c000020};
  std::mt19937_64 rng(0x4c41);
  for (unsigned i = 0; i < 10000; ++i) {
    uint64_t value = rng();
    factor::loongarch_store_literal(literal, value);
    assert(factor::loongarch_load_literal(literal) == value);
  }
  for (int64_t value : {int64_t(-2147483648), int64_t(-4096), int64_t(-4),
                       int64_t(0), int64_t(2048), int64_t(2147481596)}) {
    for (uint32_t opcode : {uint32_t(0x4c000181), uint32_t(0x02c0018c)}) {
      uint32_t pair[2] = {0x1c00000c, opcode};
      factor::loongarch_store_pair(pair, value);
      assert(factor::loongarch_pair_displacement(pair) == value);
    }
  }
#if defined(__loongarch64)
  auto* code = (uint32_t*)mmap(nullptr, 4096, PROT_READ | PROT_WRITE | PROT_EXEC,
    MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  assert(code != MAP_FAILED);
  for (unsigned i = 0; i < 9; ++i) code[i] = literal[i];
  for (uint64_t value : {uint64_t(0),uint64_t(2048),UINT64_MAX,
                         uint64_t(INT64_MIN),uint64_t(0x123456789abcdef0)}) {
    factor::loongarch_store_literal(code,value);
    __builtin___clear_cache((char*)code,(char*)(code+9));
    assert(((uint64_t(*)())code)() == value);
  }
  assert(munmap(code,4096) == 0);
#endif
}
