// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
#ifdef NDEBUG
#error This probe requires assertions enabled
#endif
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <initializer_list>
#define FACTOR_ASSERT assert
#include "../../vm/sparc.hpp"
int main() {
  // Deliberately unaligned instruction address with guard bytes.
  uint8_t buffer[26];
  memset(buffer, 0x55, sizeof(buffer));
  uint8_t* p = buffer + 1;
  const uint32_t words[] = {
      0x03000000, 0x82106000, 0x83287020,
      0x11000000, 0x90122000, 0x90120001};
  for (unsigned i = 0; i < 6; ++i)
    factor::sparc_store_instruction(p + i * 4, words[i]);
  const uint64_t values[] = {0, 1, 0xffffffff, 0x100000000,
      0x8000000000000000, 0xfedcba9876543210, UINT64_MAX};
  for (auto value : values) {
    factor::sparc_store_set64(p, value);
    assert(factor::sparc_load_set64(p) == value);
    assert(factor::sparc_load_instruction(p + 8) == words[2]);
    assert(factor::sparc_load_instruction(p + 20) == words[5]);
    assert((factor::sparc_load_instruction(p) & 0xffc00000) == words[0]);
    assert((factor::sparc_load_instruction(p + 12) & 0xffc00000) == words[3]);
    assert(buffer[0] == 0x55 && buffer[25] == 0x55);
  }
  for (unsigned bits : {19U, 22U, 30U}) {
    const int64_t limit = int64_t(1) << (bits + 1);
    const int64_t offsets[] = {-limit, -4, 0, 4, limit - 4};
    const uint32_t base = bits == 30 ? 0x40000000 : bits == 22 ? 0x12800000 : 0x12680000;
    for (auto offset : offsets) {
      factor::sparc_store_instruction(p, base);
      factor::sparc_store_displacement(p, offset, bits);
      assert(factor::sparc_displacement(p, bits) == offset);
      assert((factor::sparc_load_instruction(p) & ~((uint32_t(1) << bits) - 1)) == base);
    }
  }
  puts("SPARC instruction relocation boundary and unaligned/endian probes passed");
}
