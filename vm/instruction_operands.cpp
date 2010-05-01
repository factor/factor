#include "master.hpp"

namespace factor
{

instruction_operand::instruction_operand(relocation_entry rel_, code_block *compiled_, cell index_) :
	rel(rel_), compiled(compiled_), index(index_), pointer((cell)compiled_->entry_point() + rel_.rel_offset()) {}

/* Load a 32-bit value from a PowerPC LIS/ORI sequence */
fixnum instruction_operand::load_value_2_2()
{
	cell *ptr = (cell *)pointer;
	cell hi = (ptr[-2] & 0xffff);
	cell lo = (ptr[-1] & 0xffff);
	return hi << 16 | lo;
}

/* Load a value from a bitfield of a PowerPC instruction */
fixnum instruction_operand::load_value_masked(cell mask, cell bits, cell shift)
{
	s32 *ptr = (s32 *)(pointer - sizeof(u32));

	return (((*ptr & (s32)mask) << bits) >> bits) << shift;
}

fixnum instruction_operand::load_value(cell relative_to)
{
	switch(rel.rel_class())
	{
	case RC_ABSOLUTE_CELL:
		return *(cell *)(pointer - sizeof(cell));
	case RC_ABSOLUTE:
		return *(u32 *)(pointer - sizeof(u32));
	case RC_RELATIVE:
		return *(s32 *)(pointer - sizeof(u32)) + relative_to;
	case RC_ABSOLUTE_PPC_2_2:
		return load_value_2_2();
	case RC_ABSOLUTE_PPC_2:
		return load_value_masked(rel_absolute_ppc_2_mask,16,0);
	case RC_RELATIVE_PPC_2:
		return load_value_masked(rel_relative_ppc_2_mask,16,0) + relative_to - sizeof(cell);
	case RC_RELATIVE_PPC_3:
		return load_value_masked(rel_relative_ppc_3_mask,6,0) + relative_to - sizeof(cell);
	case RC_RELATIVE_ARM_3:
		return load_value_masked(rel_relative_arm_3_mask,6,2) + relative_to + sizeof(cell);
	case RC_INDIRECT_ARM:
		return load_value_masked(rel_indirect_arm_mask,20,0) + relative_to;
	case RC_INDIRECT_ARM_PC:
		return load_value_masked(rel_indirect_arm_mask,20,0) + relative_to + sizeof(cell);
	case RC_ABSOLUTE_2:
		return *(u16 *)(pointer - sizeof(u16));
	case RC_ABSOLUTE_1:
		return *(u8 *)(pointer - sizeof(u8));
	default:
		critical_error("Bad rel class",rel.rel_class());
		return 0;
	}
}

fixnum instruction_operand::load_value()
{
	return load_value(pointer);
}

cell instruction_operand::load_float()
{
	return (cell)load_value() - boxed_float_offset;
}

cell instruction_operand::load_float(cell pointer)
{
	return (cell)load_value(pointer) - boxed_float_offset;
}

cell instruction_operand::load_byte_array()
{
	return (cell)load_value() - byte_array_offset;
}

cell instruction_operand::load_byte_array(cell pointer)
{
	return (cell)load_value(pointer) - byte_array_offset;
}

code_block *instruction_operand::load_code_block(cell relative_to)
{
	return ((code_block *)load_value(relative_to) - 1);
}

code_block *instruction_operand::load_code_block()
{
	return load_code_block(pointer);
}

/* Store a 32-bit value into a PowerPC LIS/ORI sequence */
void instruction_operand::store_value_2_2(fixnum value)
{
	cell *ptr = (cell *)pointer;
	ptr[-2] = ((ptr[-2] & ~0xffff) | ((value >> 16) & 0xffff));
	ptr[-1] = ((ptr[-1] & ~0xffff) | (value & 0xffff));
}

/* Store a value into a bitfield of a PowerPC instruction */
void instruction_operand::store_value_masked(fixnum value, cell mask, cell shift)
{
	u32 *ptr = (u32 *)(pointer - sizeof(u32));
	*ptr = (u32)((*ptr & ~mask) | ((value >> shift) & mask));
}

void instruction_operand::store_value(fixnum absolute_value)
{
	fixnum relative_value = absolute_value - pointer;

	switch(rel.rel_class())
	{
	case RC_ABSOLUTE_CELL:
		*(cell *)(pointer - sizeof(cell)) = absolute_value;
		break;
	case RC_ABSOLUTE:
		*(u32 *)(pointer - sizeof(u32)) = (u32)absolute_value;
		break;
	case RC_RELATIVE:
		*(s32 *)(pointer - sizeof(s32)) = (s32)relative_value;
		break;
	case RC_ABSOLUTE_PPC_2_2:
		store_value_2_2(absolute_value);
		break;
	case RC_ABSOLUTE_PPC_2:
		store_value_masked(absolute_value,rel_absolute_ppc_2_mask,0);
		break;
	case RC_RELATIVE_PPC_2:
		store_value_masked(relative_value + sizeof(cell),rel_relative_ppc_2_mask,0);
		break;
	case RC_RELATIVE_PPC_3:
		store_value_masked(relative_value + sizeof(cell),rel_relative_ppc_3_mask,0);
		break;
	case RC_RELATIVE_ARM_3:
		store_value_masked(relative_value - sizeof(cell),rel_relative_arm_3_mask,2);
		break;
	case RC_INDIRECT_ARM:
		store_value_masked(relative_value,rel_indirect_arm_mask,0);
		break;
	case RC_INDIRECT_ARM_PC:
		store_value_masked(relative_value - sizeof(cell),rel_indirect_arm_mask,0);
		break;
	case RC_ABSOLUTE_2:
		*(u16 *)(pointer - sizeof(u16)) = (u16)absolute_value;
		break;
	case RC_ABSOLUTE_1:
		*(u8 *)(pointer - sizeof(u8)) = (u8)absolute_value;
		break;
	default:
		critical_error("Bad rel class",rel.rel_class());
		break;
	}
}

void instruction_operand::store_float(cell value)
{
	store_value((fixnum)value + boxed_float_offset);
}

void instruction_operand::store_byte_array(cell value)
{
	store_value((fixnum)value + byte_array_offset);
}

void instruction_operand::store_code_block(code_block *compiled)
{
	store_value((cell)compiled->entry_point());
}

}
