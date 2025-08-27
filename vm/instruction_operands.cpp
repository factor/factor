#include "master.hpp"

namespace factor {

instruction_operand::instruction_operand(relocation_entry rel,
                                         code_block* compiled, cell index)
    : rel(rel),
      compiled(compiled),
      index(index),
      pointer(compiled->entry_point() + rel.offset()) {
  // Ensure the offset is valid for the relocation class
  cell min_offset = 0;
  switch (rel.klass()) {
    case RC_ABSOLUTE_CELL:
      min_offset = sizeof(cell);
      break;
    case RC_ABSOLUTE:
    case RC_RELATIVE:
    case RC_RELATIVE_ARM_B:
    case RC_RELATIVE_ARM_B_COND_LDR:
    case RC_ABSOLUTE_ARM_LDUR:
    case RC_ABSOLUTE_ARM_CMP:
      min_offset = sizeof(uint32_t);
      break;
    case RC_ABSOLUTE_2:
      min_offset = sizeof(uint16_t);
      break;
    case RC_ABSOLUTE_1:
      min_offset = sizeof(uint8_t);
      break;
  }
  
  if (rel.offset() < min_offset) {
    critical_error("Relocation offset too small", rel.offset());
  }
  
  // Also check we're not going past the end
  if (pointer > compiled->entry_point() + compiled->size()) {
    critical_error("Relocation offset too large", rel.offset());
  }
}

// Load a value from a bitfield of an ARM/RISC-V instruction
fixnum instruction_operand::load_value_masked(cell msb, cell lsb,
                                              cell scaling) {
  // Ensure we're not reading before the code block
  FACTOR_ASSERT(pointer >= compiled->entry_point() + sizeof(uint32_t));
  
  // Use memcpy to avoid alignment issues
  int32_t value;
  memcpy(&value, reinterpret_cast<void*>(pointer - sizeof(uint32_t)), sizeof(int32_t));

  return value << (31 - msb) >> (31 - msb + lsb) << scaling;
}

fixnum instruction_operand::load_value(cell relative_to) {
  switch (rel.klass()) {
    case RC_ABSOLUTE_CELL: {
      FACTOR_ASSERT(pointer >= compiled->entry_point() + sizeof(cell));
      cell value;
      memcpy(&value, reinterpret_cast<void*>(pointer - sizeof(cell)), sizeof(cell));
      return value;
    }
    case RC_ABSOLUTE: {
      FACTOR_ASSERT(pointer >= compiled->entry_point() + sizeof(uint32_t));
      uint32_t value;
      memcpy(&value, reinterpret_cast<void*>(pointer - sizeof(uint32_t)), sizeof(uint32_t));
      return value;
    }
    case RC_ABSOLUTE_2: {
      FACTOR_ASSERT(pointer >= compiled->entry_point() + sizeof(uint16_t));
      uint16_t value;
      memcpy(&value, reinterpret_cast<void*>(pointer - sizeof(uint16_t)), sizeof(uint16_t));
      return value;
    }
    case RC_ABSOLUTE_1:
      FACTOR_ASSERT(pointer >= compiled->entry_point() + sizeof(uint8_t));
      return *(uint8_t*)(pointer - sizeof(uint8_t));
    case RC_RELATIVE: {
      FACTOR_ASSERT(pointer >= compiled->entry_point() + sizeof(uint32_t));
      int32_t value;
      memcpy(&value, reinterpret_cast<void*>(pointer - sizeof(uint32_t)), sizeof(int32_t));
      return value + relative_to;
    }
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
  return (reinterpret_cast<code_block*>(load_value(pointer)) - 1);
}

// Store a value into a bitfield of an ARM/RISC-V instruction
void instruction_operand::store_value_masked(fixnum value, cell mask,
                                             cell lsb, cell scaling) {
  FACTOR_ASSERT(pointer >= compiled->entry_point() + sizeof(uint32_t));
  
  // Use memcpy to avoid alignment issues
  uint32_t current;
  memcpy(&current, reinterpret_cast<void*>(pointer - sizeof(uint32_t)), sizeof(uint32_t));
  current = (uint32_t)((current & ~mask) | (value >> scaling << lsb & mask));
  memcpy(reinterpret_cast<void*>(pointer - sizeof(uint32_t)), &current, sizeof(uint32_t));
}

void instruction_operand::store_value(fixnum absolute_value) {
  fixnum relative_value = absolute_value - pointer;

  switch (rel.klass()) {
    case RC_ABSOLUTE_CELL: {
      FACTOR_ASSERT(pointer >= compiled->entry_point() + sizeof(cell));
      cell value = absolute_value;
      memcpy(reinterpret_cast<void*>(pointer - sizeof(cell)), &value, sizeof(cell));
      break;
    }
    case RC_ABSOLUTE: {
      FACTOR_ASSERT(pointer >= compiled->entry_point() + sizeof(uint32_t));
      uint32_t value = (uint32_t)absolute_value;
      memcpy((void*)(pointer - sizeof(uint32_t)), &value, sizeof(uint32_t));
      break;
    }
    case RC_ABSOLUTE_2: {
      FACTOR_ASSERT(pointer >= compiled->entry_point() + sizeof(uint16_t));
      uint16_t value = (uint16_t)absolute_value;
      memcpy((void*)(pointer - sizeof(uint16_t)), &value, sizeof(uint16_t));
      break;
    }
    case RC_ABSOLUTE_1:
      FACTOR_ASSERT(pointer >= compiled->entry_point() + sizeof(uint8_t));
      *(uint8_t*)(pointer - sizeof(uint8_t)) = (uint8_t)absolute_value;
      break;
    case RC_RELATIVE: {
      FACTOR_ASSERT(pointer >= compiled->entry_point() + sizeof(int32_t));
      int32_t value = (int32_t)relative_value;
      memcpy((void*)(pointer - sizeof(int32_t)), &value, sizeof(int32_t));
      break;
    }
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
