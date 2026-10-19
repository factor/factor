// Execute natively with vm/instruction_operands.cpp, on ARM32.
#include "../master.hpp"
#include <cassert>
namespace factor {
void critical_error(const char* message, cell value) {
  fprintf(stderr, "%s: %lu\n", message, (unsigned long)value);
  ::abort();
}
}
int main() {
  using namespace factor;
  static_assert(sizeof(cell) == 4, "Native ARM32 test");
  struct { code_block block; uint32_t instruction; } buffer;
  instruction_operand operand(relocation_entry(RT_HERE, RC_RELATIVE_ARM_B, 4), &buffer.block, 0);
  for (uint32_t opcode : {0xea000000u, 0xeb000000u, 0x1a000000u, 0x0b000000u}) {
    for (int32_t displacement : {-33554432, -4, 0, 4, 33554428}) {
      buffer.instruction = opcode;
      const cell target = operand.pointer + 4 + cell(displacement);
      operand.store_value(fixnum(target));
      assert((buffer.instruction & 0xff000000u) == opcode);
      assert((buffer.instruction & 0xffffffu) == (uint32_t(displacement >> 2) & 0xffffffu));
      assert(cell(operand.load_value(operand.pointer)) == target);
      assert(cell(operand.load_value(operand.pointer + 32)) == target + 32);
    }
  }
  int protection = PROT_READ | PROT_WRITE | PROT_EXEC;
#if defined(__NetBSD__)
  protection |= PROT_MPROTECT(PROT_EXEC);
#endif
  auto p = (uint32_t*)mmap(nullptr, 4096, protection,
                          MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  assert(p != MAP_FAILED);
  p[0] = 0xea000000; p[1] = 0xe3a00063; p[2] = 0xe3a0002a; p[3] = 0xe12fff1e;
  operand.pointer = (cell)(p + 1);
  operand.store_value(fixnum((cell)(p + 2)));
  __builtin___clear_cache((char*)p, (char*)(p + 4));
  auto invoke = (unsigned (*)())p;
  assert(invoke() == 42);
  p[0] = 0xe3a00000; p[1] = 0xe2800001; p[2] = 0xe3500003;
  p[3] = 0xba000000; p[4] = 0xe12fff1e;
  operand.pointer = (cell)(p + 4);
  operand.store_value(fixnum((cell)(p + 1)));
  assert(p[3] == 0xbafffffc);
  __builtin___clear_cache((char*)p, (char*)(p + 5));
  assert(invoke() == 3);
  assert(munmap(p, 4096) == 0);
  puts("ARM32 branch relocation PC+8, signed24, opcode preservation and native forward/backward execution pass");
}
