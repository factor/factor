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
		c_to_factor_func = (c_to_factor_func_type)c_to_factor_block->xt();
	}

	c_to_factor_func(quot);
}

void factor_vm::unwind_native_frames(cell quot, stack_frame *to)
{
	tagged<word> unwind_native_frames_word(special_objects[UNWIND_NATIVE_FRAMES_WORD]);
	unwind_native_frames_func_type unwind_native_frames_func = (unwind_native_frames_func_type)unwind_native_frames_word->xt;
	unwind_native_frames_func(quot,to);
}

}
