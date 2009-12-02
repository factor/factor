#include "master.hpp"

namespace factor
{

instruction_operand::instruction_operand(relocation_entry rel_, code_block *compiled_, cell index_) :
	rel(rel_), compiled(compiled_), index(index_), pointer((cell)compiled_->xt() + rel_.rel_offset()) {}

/* Load a 32-bit value from a PowerPC LIS/ORI sequence */
fixnum instruction_operand::load_value_2_2()
{
	cell *ptr = (cell *)pointer;
	cell hi = (ptr[-1] & 0xffff);
	cell lo = (ptr[ 0] & 0xffff);
	return hi << 16 | lo;
}

/* Load a value from a bitfield of a PowerPC instruction */
fixnum instruction_operand::load_value_masked(cell mask, cell bits, cell shift)
{
	fixnum *ptr = (fixnum *)pointer;

	return (((*ptr & mask) << bits) >> bits) << shift;
}

fixnum instruction_operand::load_value(cell relative_to)
{
	switch(rel.rel_class())
	{
	case RC_ABSOLUTE_CELL:
		return *(cell *)pointer;
	case RC_ABSOLUTE:
		return *(u32*)pointer;
	case RC_RELATIVE:
		return *(s32*)pointer + relative_to + sizeof(u32);
	case RC_ABSOLUTE_PPC_2_2:
		return load_value_2_2();
	case RC_ABSOLUTE_PPC_2:
		return load_value_masked(rel_absolute_ppc_2_mask,0,0);
	case RC_RELATIVE_PPC_2:
		return load_value_masked(rel_relative_ppc_2_mask,16,0) + relative_to;
	case RC_RELATIVE_PPC_3:
		return load_value_masked(rel_relative_ppc_3_mask,6,0) + relative_to;
	case RC_RELATIVE_ARM_3:
		return load_value_masked(rel_relative_arm_3_mask,6,2) + relative_to + sizeof(cell) * 2;
	case RC_INDIRECT_ARM:
		return load_value_masked(rel_indirect_arm_mask,20,0) + relative_to + sizeof(cell);
	case RC_INDIRECT_ARM_PC:
		return load_value_masked(rel_indirect_arm_mask,20,0) + relative_to + sizeof(cell) * 2;
	default:
		critical_error("Bad rel class",rel.rel_class());
		return 0;
	}
}

fixnum instruction_operand::load_value()
{
	return load_value(pointer);
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
	ptr[-1] = ((ptr[-1] & ~0xffff) | ((value >> 16) & 0xffff));
	ptr[ 0] = ((ptr[ 0] & ~0xffff) | (value & 0xffff));
}

/* Store a value into a bitfield of a PowerPC instruction */
void instruction_operand::store_value_masked(fixnum value, cell mask, cell shift)
{
	cell *ptr = (cell *)pointer;

	/* This is unaccurate but good enough */
	fixnum test = (fixnum)mask >> 1;
	if(value <= -test || value >= test)
		critical_error("Value does not fit inside relocation",0);

	*ptr = ((*ptr & ~mask) | ((value >> shift) & mask));
}

void instruction_operand::store_value(fixnum absolute_value)
{
	fixnum relative_value = absolute_value - pointer;

	switch(rel.rel_class())
	{
	case RC_ABSOLUTE_CELL:
		*(cell *)pointer = absolute_value;
		break;
	case RC_ABSOLUTE:
		*(u32*)pointer = absolute_value;
		break;
	case RC_RELATIVE:
		*(s32*)pointer = relative_value - sizeof(u32);
		break;
	case RC_ABSOLUTE_PPC_2_2:
		store_value_2_2(absolute_value);
		break;
	case RC_ABSOLUTE_PPC_2:
		store_value_masked(absolute_value,rel_absolute_ppc_2_mask,0);
		break;
	case RC_RELATIVE_PPC_2:
		store_value_masked(relative_value,rel_relative_ppc_2_mask,0);
		break;
	case RC_RELATIVE_PPC_3:
		store_value_masked(relative_value,rel_relative_ppc_3_mask,0);
		break;
	case RC_RELATIVE_ARM_3:
		store_value_masked(relative_value - sizeof(cell) * 2,rel_relative_arm_3_mask,2);
		break;
	case RC_INDIRECT_ARM:
		store_value_masked(relative_value - sizeof(cell),rel_indirect_arm_mask,0);
		break;
	case RC_INDIRECT_ARM_PC:
		store_value_masked(relative_value - sizeof(cell) * 2,rel_indirect_arm_mask,0);
		break;
	default:
		critical_error("Bad rel class",rel.rel_class());
		break;
	}
}

void instruction_operand::store_code_block(code_block *compiled)
{
	store_value((cell)compiled->xt());
}

}
