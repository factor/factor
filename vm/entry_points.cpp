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

void factor_vm::unwind_native_frames(cell quot, stack_frame *to)
{
	tagged<word> unwind_native_frames_word(special_objects[UNWIND_NATIVE_FRAMES_WORD]);
	unwind_native_frames_func_type unwind_native_frames_func = (unwind_native_frames_func_type)unwind_native_frames_word->entry_point;
	unwind_native_frames_func(quot,to);
}

cell factor_vm::get_fpu_state()
{
	tagged<word> get_fpu_state_word(special_objects[GET_FPU_STATE_WORD]);
	get_fpu_state_func_type get_fpu_state_func = (get_fpu_state_func_type)get_fpu_state_word->entry_point;
	return get_fpu_state_func();
}

void factor_vm::set_fpu_state(cell state)
{
	tagged<word> set_fpu_state_word(special_objects[SET_FPU_STATE_WORD]);
	set_fpu_state_func_type set_fpu_state_func = (set_fpu_state_func_type)set_fpu_state_word->entry_point;
	set_fpu_state_func(state);
}

}
