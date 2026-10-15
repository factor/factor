// Standalone dispatch oracle. Build with a FACTOR_* CPU and native helpers;
// no complete VM or boot image is required.
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <assert.h>
#include <stdexcept>
#include <iostream>
#define FACTOR_ASSERT assert
namespace factor {
using cell = uintptr_t;
using fixnum = intptr_t;
enum relocation_class { RC_NATIVE_0 = 14, RC_NATIVE_1 = 15 };
inline void critical_error(const char*, cell) { throw std::runtime_error("invalid relocation"); }
}
#include "../native_relocations.hpp"

int main() {
  using namespace factor;
  using namespace factor::cpu;
#if defined(FACTOR_M88K)
  uint32_t literal[] = {0x5ea00000, 0x5ab50000};
  cell end = cell(literal) + sizeof(literal);
  store_native_operand(RC_NATIVE_0, end, 0x89abcdef);
  assert(literal[0] == 0x5ea089ab && literal[1] == 0x5ab5cdef);
  assert(uint32_t(load_native_operand(RC_NATIVE_0, end, 0)) == 0x89abcdef);
  uint32_t branch = 0xc8000000;
  end = cell(&branch) + sizeof(branch);
  store_native_operand(RC_NATIVE_1, end, fixnum(end - 8));
  assert(branch == 0xcbffffff && load_native_operand(RC_NATIVE_1, end, 1004) == 996);
  store_native_operand(RC_NATIVE_1, end, fixnum(end + 4));
  assert(branch == 0xc8000002 && load_native_operand(RC_NATIVE_1, end, 1004) == 1008);
#elif defined(FACTOR_ALPHA)
  uint32_t branch = 0xc0000000;
  cell end = cell(&branch) + 4;
  store_native_operand(RC_NATIVE_0, end, fixnum(end - 4));
  assert(branch == 0xc01fffff);
  assert(load_native_operand(RC_NATIVE_0, end, 1004) == 1000);
  bool rejected = false;
  try { store_native_operand(RC_NATIVE_0, end, fixnum(end + 2)); } catch (...) { rejected = true; }
  assert(rejected);
  uint32_t literal[7] = {};
  end = cell(literal) + sizeof(literal);
  store_native_operand(RC_NATIVE_1, end, fixnum(UINT64_C(0xfedcba9876543210)));
  assert(cell(load_native_operand(RC_NATIVE_1, end, 0)) == UINT64_C(0xfedcba9876543210));
#elif defined(FACTOR_HPPA)
  uint32_t literal[] = {0x22c00000, 0x36d60000};
  cell end = cell(literal) + sizeof(literal);
  store_native_operand(RC_NATIVE_0, end, 0x89abcdef);
  assert(uint32_t(load_native_operand(RC_NATIVE_0, end, 0)) == 0x89abcdef);
  store_native_operand(RC_NATIVE_1, end, -8192);
  assert(load_native_operand(RC_NATIVE_1, end, 0) == -8192);
  bool rejected = false;
  try { store_native_operand(RC_NATIVE_1, end, 8192); } catch (...) { rejected = true; }
  assert(rejected);
#elif defined(FACTOR_LOONGARCH64)
  uint32_t literal[8] = {0x14000004, 0x02c00084, 0x00413084, 0x02c00084,
                         0x00413084, 0x02c00084, 0x00413084, 0x02c00084};
  cell end = cell(literal) + sizeof(literal);
  store_native_operand(RC_NATIVE_1, end, fixnum(UINT64_C(0xfedcba9876543210)));
  assert(cell(load_native_operand(RC_NATIVE_1, end, 0)) == UINT64_C(0xfedcba9876543210));
  uint32_t pair[] = {0x1c00000c, 0x4c000181};
  end = cell(pair) + sizeof(pair);
  store_native_operand(RC_NATIVE_0, end, fixnum(end - 12));
  assert(load_native_operand(RC_NATIVE_0, end, 1008) == 996);
#elif defined(FACTOR_MIPS)
  uint32_t narrow[] = {0x3c020000, 0x34420000};
  uint32_t wide[] = {0x34020000, 0x00021438, 0x34420000, 0x00021438,
                     0x34420000, 0x00021438, 0x34420000};
  cell end = sizeof(cell) == 8 ? cell(wide) + sizeof(wide) : cell(narrow) + sizeof(narrow);
  store_native_operand(RC_NATIVE_0, end, -1);
  assert(load_native_operand(RC_NATIVE_0, end, 0) == -1);
  if (sizeof(cell) == 8) assert(wide[0] == 0x3402ffff && wide[6] == 0x3442ffff);
  else assert(narrow[0] == 0x3c02ffff && narrow[1] == 0x3442ffff);
  uint32_t immediate = 0x8c820000;
  end = cell(&immediate) + 4;
  store_native_operand(RC_NATIVE_1, end, -32768);
  assert(immediate == 0x8c828000 && load_native_operand(RC_NATIVE_1, end, 0) == -32768);
  bool rejected = false;
  try { store_native_operand(RC_NATIVE_1, end, 32768); } catch (...) { rejected = true; }
  assert(rejected);
#elif defined(FACTOR_PPC)
  uint32_t branch = 0x48000001;
  cell end = cell(&branch) + 4;
  store_native_operand(RC_NATIVE_1, end, fixnum(end - 8));
  assert(branch == 0x4bfffffd && load_native_operand(RC_NATIVE_1, end, 1004) == 996);
  branch = 0x48000003;
  bool rejected = false;
  try { (void)load_native_operand(RC_NATIVE_1, end, 0); } catch (...) { rejected = true; }
  assert(rejected);
#elif defined(FACTOR_SPARC)
  uint8_t branch[] = {0x40, 0, 0, 0};
  cell end = cell(branch) + 4;
  store_native_operand(RC_NATIVE_0, end, fixnum(end - 8));
  const uint8_t expected[] = {0x7f, 0xff, 0xff, 0xff};
  assert(!memcmp(branch, expected, 4));
  assert(load_native_operand(RC_NATIVE_0, end, 1004) == 996);
  memset(branch, 0, 4);
  bool rejected = false;
  try { (void)load_native_operand(RC_NATIVE_0, end, 0); } catch (...) { rejected = true; }
  assert(rejected);
#elif defined(FACTOR_S390X)
  uint8_t branch[] = {0xc0, 0xe5, 0, 0, 0, 0};
  cell end = cell(branch) + 6;
  store_native_operand(RC_NATIVE_0, end, fixnum(end + 4));
  const uint8_t expected[] = {0xc0, 0xe5, 0, 0, 0, 5};
  assert(!memcmp(branch, expected, 6));
  assert(load_native_operand(RC_NATIVE_0, end, 1006) == 1010);
  uint8_t literal[] = {0xc0, 0x28, 0, 0, 0, 0, 0xc0, 0x29, 0, 0, 0, 0};
  end = cell(literal) + 12;
  store_native_operand(RC_NATIVE_1, end, fixnum(UINT64_C(0xfedcba9876543210)));
  const uint8_t imm[] = {0xc0, 0x28, 0xfe, 0xdc, 0xba, 0x98, 0xc0, 0x29, 0x76, 0x54, 0x32, 0x10};
  assert(!memcmp(literal, imm, 12));
  assert(cell(load_native_operand(RC_NATIVE_1, end, 0)) == UINT64_C(0xfedcba9876543210));
#else
  bool rejected = false;
  try { (void)load_native_operand(RC_NATIVE_0, 0, 0); } catch (...) { rejected = true; }
  assert(rejected);
  rejected = false;
  try { store_native_operand(RC_NATIVE_1, 0, 0); } catch (...) { rejected = true; }
  assert(rejected);
#endif
  std::cout << "native relocation dispatch passed\n";
}
