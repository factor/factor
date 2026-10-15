#include <initializer_list>
#include <cassert>
#include <cstdio>
#include "../../sh.hpp"
using namespace factor;
int main() {
  for (bool le : {false, true}) {
    alignas(4) uint8_t code[16] = {};
    sh_store_instruction(code, 0xd002, le);
    sh_store_instruction(code + 2, 0x400b, le);
    sh_store_instruction(code + 4, 0x0009, le);
    sh_store_literal(code + 12, 0x81234567, le);
    assert(sh_call_site_p(code + 6, le));
    assert(sh_call_literal(code + 6, le) == code + 12);
    assert(sh_load_literal(sh_call_literal(code + 6, le), le) == 0x81234567);
    sh_store_instruction(code + 2, 0x402b, le);
    assert(sh_call_site_p(code + 6, le));
    sh_store_instruction(code + 4, 0x000b, le);
    assert(!sh_call_site_p(code + 6, le));
    // The PC can be two-byte aligned without being four-byte aligned.
    assert(sh_literal_address(0x1002, 0xd001) == 0x1008);
    for (int displacement : {-4092, -2, 0, 4, 4098})
      assert(sh_branch_displacement(0xa000 | sh_branch_bits(displacement, 12), 12) == displacement);
    for (int displacement : {-252, -2, 0, 4, 258})
      assert(sh_branch_displacement(0x8900 | sh_branch_bits(displacement, 8), 8) == displacement);
  }
  puts("SH3/SH4 instruction and literal tests passed (little and big endian)");
}
