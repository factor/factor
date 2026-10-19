// Freestanding ELF probe: executes each byte order without substituting a
// little-endian libc for a big-endian userspace. This is not a guest OS test.
#include "../../sh.hpp"
extern "C" int sh_freestanding_validate(void*);
extern "C" int sh_freestanding_leaf(unsigned, unsigned);
extern "C" int sh_freestanding_main() {
  constexpr bool le = __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__;
  alignas(4) unsigned char code[16] = {};
  factor::sh_store_instruction(code, 0xd002, le);
  factor::sh_store_instruction(code + 2, 0x400b, le);
  factor::sh_store_instruction(code + 4, 0x0009, le);
  factor::sh_store_literal(code + 12, 0x12345678, le);
  const int error = sh_freestanding_validate(code);
  if (error) return error;
  if (sh_freestanding_leaf(5, 7) != 42) return 4;
  return 0;
}
