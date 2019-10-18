#include "master.hpp"

namespace factor
{

void factor_vm::c_to_factor(cell quot)
{
	/* First time this is called, wrap the c-to-factor sub-primitive inside
	of a callback stub, which saves and restores non-volatile registers
	as per platform ABI conventions, so that the Factor compiler can treat
	all registers as volatile */
	if(!c_to_factor_func)
	{
		tagged<word> c_to_factor_word(special_objects[C_TO_FACTOR_WORD]);
		code_block *c_to_factor_block = callbacks->add(c_to_factor_word.value(),0);
		c_to_factor_func = (c_to_factor_func_type)c_to_factor_block->entry_point();
	}

	c_to_factor_func(quot);
}

template<typename Func> Func factor_vm::get_entry_point(cell n)
{
	/* We return word->code->entry_point() and not word->entry_point,
	because if profiling is enabled, we don't want to go through the
	entry point's profiling stub. This clobbers registers, since entry
	points use the C ABI and not the Factor ABI. */
	tagged<word> entry_point_word(special_objects[n]);
	return (Func)entry_point_word->code->entry_point();
}

void factor_vm::unwind_native_frames(cell quot, stack_frame *to)
{
	get_entry_point<unwind_native_frames_func_type>(UNWIND_NATIVE_FRAMES_WORD)(quot,to);
}

cell factor_vm::get_fpu_state()
{
	return get_entry_point<get_fpu_state_func_type>(GET_FPU_STATE_WORD)();
}

void factor_vm::set_fpu_state(cell state)
{
	get_entry_point<set_fpu_state_func_type>(GET_FPU_STATE_WORD)(state);
}

}
