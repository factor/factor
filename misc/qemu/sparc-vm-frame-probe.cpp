// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
// Native header/frame/inline-cache test; not a Factor startup test.
#ifdef NDEBUG
#error This probe requires assertions enabled
#endif
#include "../../vm/master.hpp"
#include <cassert>
int main() {
  using namespace factor;
  cell frame[16] = {};
  const cell address = (cell)frame;
  frame[14] = address + 256 - SPARC_STACK_BIAS;
  frame[15] = 0x12345670;
  assert(sparc_frame_predecessor(address) == address + 256);
  assert(sparc_frame_return_address(address) == 0x12345678);
  sparc_set_frame_return_address(address, 0x76543218);
  assert(frame[15] == 0x76543210);
  uint8_t code[40] = {};
  const cell site = (cell)code;
  sparc_store_instruction(code, 0x40000000);
  set_call_target(site + 8, site - 4);
  assert((cell)get_call_target(site + 8) == site - 4);
  assert(!tail_call_site_p(site + 8));
  sparc_store_instruction(code, 0x10800000);
  set_call_target(site + 8, site + 16);
  assert((cell)get_call_target(site + 8) == site + 16);
  assert(tail_call_site_p(site + 8));
#ifdef FACTOR_64
  const uint32_t words[] = {0x05000000,0x8410a000,0x8528b020,0x03000000,0x82106000,0x82104002};
  const unsigned bytes = 24;
  const cell target = 0xfedcba9876543210UL;
#else
  const uint32_t words[] = {0x03000000,0x82106000};
  const unsigned bytes = 8;
  const cell target = 0xfedcba98UL;
#endif
  for (unsigned i = 0; i < sizeof(words)/sizeof(words[0]); ++i)
    sparc_store_instruction(code + i*4, words[i]);
  sparc_store_instruction(code + bytes, 0x9fc06000);
  sparc_store_instruction(code + bytes + 4, 0x01000000);
  set_call_target(site + bytes + 8, target);
  assert((cell)get_call_target(site + bytes + 8) == target);
  assert(!tail_call_site_p(site + bytes + 8));
  sparc_store_instruction(code + bytes, 0x81c06000);
  assert(tail_call_site_p(site + bytes + 8));
  puts("SPARC VM native frame chain/RA normalization and direct/indirect inline-cache patch probes passed");
}
