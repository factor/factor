#include "master.hpp"

namespace factor {

namespace {

template <typename T>
T read_unaligned(cell address) {
  T value;
  memcpy(&value, reinterpret_cast<void*>(address), sizeof(T));
  return value;
}

template <typename T>
void write_unaligned(cell address, T value) {
  memcpy(reinterpret_cast<void*>(address), &value, sizeof(T));
}

}  // namespace

instruction_operand::instruction_operand(relocation_entry rel,
                                         code_block* compiled, cell index)
    : rel(rel),
      compiled(compiled),
      index(index),
      pointer(compiled->entry_point() + rel.offset()) {}

// Load a value from a bitfield of an ARM/RISC-V instruction
fixnum instruction_operand::load_value_masked(cell msb, cell lsb,
                                              cell scaling) {
  int32_t value = read_unaligned<int32_t>(pointer - sizeof(uint32_t));
  return value << (31 - msb) >> (31 - msb + lsb) << scaling;
}

fixnum instruction_operand::load_value(cell relative_to) {
  switch (rel.klass()) {
    case RC_ABSOLUTE_CELL:
      return read_unaligned<cell>(pointer - sizeof(cell));
    case RC_ABSOLUTE:
      return read_unaligned<uint32_t>(pointer - sizeof(uint32_t));
    case RC_ABSOLUTE_2:
      return read_unaligned<uint16_t>(pointer - sizeof(uint16_t));
    case RC_ABSOLUTE_1:
      return read_unaligned<uint8_t>(pointer - sizeof(uint8_t));
    case RC_RELATIVE:
      return read_unaligned<int32_t>(pointer - sizeof(uint32_t)) + relative_to;
    case RC_RELATIVE_ARM_B:
      return load_value_masked(25, 0, 2) + relative_to - 4;
    case RC_RELATIVE_ARM_B_COND_LDR:
      return load_value_masked(23, 5, 2) + relative_to - 4;
    case RC_ABSOLUTE_ARM_LDUR:
      return load_value_masked(20, 12, 0);
    case RC_ABSOLUTE_ARM_CMP:
      return load_value_masked(21, 10, 0);
    default:
      critical_error("Bad rel class", rel.klass());
      return 0;
  }
}

code_block* instruction_operand::load_code_block() {
  return reinterpret_cast<code_block*>(load_value(pointer)) - 1;
}

// Store a value into a bitfield of an ARM/RISC-V instruction
void instruction_operand::store_value_masked(fixnum value, cell mask,
                                             cell lsb, cell scaling) {
  uint32_t current = read_unaligned<uint32_t>(pointer - sizeof(uint32_t));
  current = (uint32_t)((current & ~mask) | (value >> scaling << lsb & mask));
  write_unaligned<uint32_t>(pointer - sizeof(uint32_t), current);
}

void instruction_operand::store_value(fixnum absolute_value) {
  fixnum relative_value = absolute_value - pointer;

  switch (rel.klass()) {
    case RC_ABSOLUTE_CELL:
      write_unaligned<cell>(pointer - sizeof(cell), (cell)absolute_value);
      break;
    case RC_ABSOLUTE:
      write_unaligned<uint32_t>(pointer - sizeof(uint32_t), (uint32_t)absolute_value);
      break;
    case RC_ABSOLUTE_2:
      write_unaligned<uint16_t>(pointer - sizeof(uint16_t), (uint16_t)absolute_value);
      break;
    case RC_ABSOLUTE_1:
      write_unaligned<uint8_t>(pointer - sizeof(uint8_t), (uint8_t)absolute_value);
      break;
    case RC_RELATIVE:
      write_unaligned<int32_t>(pointer - sizeof(int32_t), (int32_t)relative_value);
      break;
    case RC_RELATIVE_ARM_B:
      FACTOR_ASSERT(relative_value + 4 < 0x8000000);
      FACTOR_ASSERT(relative_value + 4 >= -0x8000000);
      FACTOR_ASSERT((relative_value & 3) == 0);
      store_value_masked(relative_value + 4, rel_arm_b_mask, 0, 2);
      break;
    case RC_RELATIVE_ARM_B_COND_LDR:
      FACTOR_ASSERT(relative_value + 4 < 0x2000000);
      FACTOR_ASSERT(relative_value + 4 >= -0x2000000);
      FACTOR_ASSERT((relative_value & 3) == 0);
      store_value_masked(relative_value + 4, rel_arm_b_cond_ldr_mask, 5, 2);
      break;
    case RC_ABSOLUTE_ARM_LDUR:
      FACTOR_ASSERT(absolute_value >= -256);
      FACTOR_ASSERT(absolute_value <= 255);
      store_value_masked(absolute_value, rel_arm_ldur_mask, 12, 0);
      break;
    case RC_ABSOLUTE_ARM_CMP:
      FACTOR_ASSERT(absolute_value >= 0);
      FACTOR_ASSERT(absolute_value <= 4095);
      store_value_masked(absolute_value, rel_arm_cmp_mask, 10, 0);
      break;
    default:
      critical_error("Bad rel class", rel.klass());
      break;
  }
}

}

