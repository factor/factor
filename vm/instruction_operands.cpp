#include "master.hpp"

namespace factor {

instruction_operand::instruction_operand(relocation_entry rel,
                                         code_block* compiled, cell index)
    : rel(rel),
      compiled(compiled),
      index(index),
      pointer((cell)compiled->entry_point() + rel.rel_offset()) {}

/* Load a 32-bit value from a PowerPC LIS/ORI sequence */
fixnum instruction_operand::load_value_2_2() {
  uint32_t* ptr = (uint32_t*)pointer;
  cell hi = (ptr[-2] & 0xffff);
  cell lo = (ptr[-1] & 0xffff);
  return hi << 16 | lo;
}

/* Load a 64-bit value from a PowerPC LIS/ORI/SLDI/ORIS/ORI sequence */
fixnum instruction_operand::load_value_2_2_2_2() {
  uint32_t* ptr = (uint32_t*)pointer;
  uint64_t hhi = (ptr[-5] & 0xffff);
  uint64_t hlo = (ptr[-4] & 0xffff);
  uint64_t lhi = (ptr[-2] & 0xffff);
  uint64_t llo = (ptr[-1] & 0xffff);
  uint64_t val = hhi << 48 | hlo << 32 | lhi << 16 | llo;
  return (cell)val;
}

/* Load a value from a bitfield of a PowerPC instruction */
fixnum instruction_operand::load_value_masked(cell mask, cell bits,
                                              cell shift) {
  int32_t* ptr = (int32_t*)(pointer - sizeof(uint32_t));

  return (((*ptr & (int32_t)mask) << bits) >> bits) << shift;
}

fixnum instruction_operand::load_value(cell relative_to) {
  switch (rel.rel_class()) {
    case RC_ABSOLUTE_CELL:
      return *(cell*)(pointer - sizeof(cell));
    case RC_ABSOLUTE:
      return *(uint32_t*)(pointer - sizeof(uint32_t));
    case RC_RELATIVE:
      return *(int32_t*)(pointer - sizeof(uint32_t)) + relative_to;
    case RC_ABSOLUTE_PPC_2_2:
      return load_value_2_2();
    case RC_ABSOLUTE_PPC_2:
      return load_value_masked(rel_absolute_ppc_2_mask, 16, 0);
    case RC_RELATIVE_PPC_2_PC:
      return load_value_masked(rel_relative_ppc_2_mask, 16, 0) + relative_to -
             4;
    case RC_RELATIVE_PPC_3_PC:
      return load_value_masked(rel_relative_ppc_3_mask, 6, 0) + relative_to - 4;
    case RC_RELATIVE_ARM_3:
      return load_value_masked(rel_relative_arm_3_mask, 6, 2) + relative_to +
             sizeof(cell);
    case RC_INDIRECT_ARM:
      return load_value_masked(rel_indirect_arm_mask, 20, 0) + relative_to;
    case RC_INDIRECT_ARM_PC:
      return load_value_masked(rel_indirect_arm_mask, 20, 0) + relative_to +
             sizeof(cell);
    case RC_ABSOLUTE_2:
      return *(uint16_t*)(pointer - sizeof(uint16_t));
    case RC_ABSOLUTE_1:
      return *(uint8_t*)(pointer - sizeof(uint8_t));
    case RC_ABSOLUTE_PPC_2_2_2_2:
      return load_value_2_2_2_2();
    default:
      critical_error("Bad rel class", rel.rel_class());
      return 0;
  }
}

fixnum instruction_operand::load_value() { return load_value(pointer); }

code_block* instruction_operand::load_code_block(cell relative_to) {
  return ((code_block*)load_value(relative_to) - 1);
}

code_block* instruction_operand::load_code_block() {
  return load_code_block(pointer);
}

/* Store a 32-bit value into a PowerPC LIS/ORI sequence */
void instruction_operand::store_value_2_2(fixnum value) {
  uint32_t* ptr = (uint32_t*)pointer;
  ptr[-2] = ((ptr[-2] & ~0xffff) | ((value >> 16) & 0xffff));
  ptr[-1] = ((ptr[-1] & ~0xffff) | (value & 0xffff));
}

/* Store a 64-bit value into a PowerPC LIS/ORI/SLDI/ORIS/ORI sequence */
void instruction_operand::store_value_2_2_2_2(fixnum value) {
  uint64_t val = value;
  uint32_t* ptr = (uint32_t*)pointer;
  ptr[-5] = ((ptr[-5] & ~0xffff) | ((val >> 48) & 0xffff));
  ptr[-4] = ((ptr[-4] & ~0xffff) | ((val >> 32) & 0xffff));
  ptr[-2] = ((ptr[-2] & ~0xffff) | ((val >> 16) & 0xffff));
  ptr[-1] = ((ptr[-1] & ~0xffff) | ((val >> 0) & 0xffff));
}

/* Store a value into a bitfield of a PowerPC instruction */
void instruction_operand::store_value_masked(fixnum value, cell mask,
                                             cell shift) {
  uint32_t* ptr = (uint32_t*)(pointer - sizeof(uint32_t));
  *ptr = (uint32_t)((*ptr & ~mask) | ((value >> shift) & mask));
}

void instruction_operand::store_value(fixnum absolute_value) {
  fixnum relative_value = absolute_value - pointer;

  switch (rel.rel_class()) {
    case RC_ABSOLUTE_CELL:
      *(cell*)(pointer - sizeof(cell)) = absolute_value;
      break;
    case RC_ABSOLUTE:
      *(uint32_t*)(pointer - sizeof(uint32_t)) = (uint32_t)absolute_value;
      break;
    case RC_RELATIVE:
      *(int32_t*)(pointer - sizeof(int32_t)) = (int32_t)relative_value;
      break;
    case RC_ABSOLUTE_PPC_2_2:
      store_value_2_2(absolute_value);
      break;
    case RC_ABSOLUTE_PPC_2:
      store_value_masked(absolute_value, rel_absolute_ppc_2_mask, 0);
      break;
    case RC_RELATIVE_PPC_2_PC:
      store_value_masked(relative_value + 4, rel_relative_ppc_2_mask, 0);
      break;
    case RC_RELATIVE_PPC_3_PC:
      store_value_masked(relative_value + 4, rel_relative_ppc_3_mask, 0);
      break;
    case RC_RELATIVE_ARM_3:
      store_value_masked(relative_value - sizeof(cell), rel_relative_arm_3_mask,
                         2);
      break;
    case RC_INDIRECT_ARM:
      store_value_masked(relative_value, rel_indirect_arm_mask, 0);
      break;
    case RC_INDIRECT_ARM_PC:
      store_value_masked(relative_value - sizeof(cell), rel_indirect_arm_mask,
                         0);
      break;
    case RC_ABSOLUTE_2:
      *(uint16_t*)(pointer - sizeof(uint16_t)) = (uint16_t)absolute_value;
      break;
    case RC_ABSOLUTE_1:
      *(uint8_t*)(pointer - sizeof(uint8_t)) = (uint8_t)absolute_value;
      break;
    case RC_ABSOLUTE_PPC_2_2_2_2:
      store_value_2_2_2_2(absolute_value);
      break;
    default:
      critical_error("Bad rel class", rel.rel_class());
      break;
  }
}

void instruction_operand::store_code_block(code_block* compiled) {
  store_value((cell)compiled->entry_point());
}

}
