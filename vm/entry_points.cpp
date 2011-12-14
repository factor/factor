#include "master.hpp"

namespace factor
{

void factor_vm::c_to_factor(cell quot)
{
	/* First time this is called, wrap the c-to-factor sub-primitive inside
	of a callback stub, which saves and restores non-volatile registers
	per platform ABI conventions, so that the Factor compiler can treat
	all registers as volatile */
	if(!c_to_factor_func)
	{
		tagged<word> c_to_factor_word(special_objects[C_TO_FACTOR_WORD]);
		code_block *c_to_factor_block = callbacks->add(c_to_factor_word.value(),0);
		void* func = c_to_factor_block->entry_point();
		CODE_TO_FUNCTION_POINTER_CALLBACK(this, func);
		c_to_factor_func = (c_to_factor_func_type)func;
	}
	c_to_factor_func(quot);
}

template<typename Func> Func factor_vm::get_entry_point(cell n)
{
	tagged<word> entry_point_word(special_objects[n]);
	return (Func)entry_point_word->entry_point;
}

void factor_vm::unwind_native_frames(cell quot, void *to)
{
	tagged<word> entry_point_word(special_objects[UNWIND_NATIVE_FRAMES_WORD]);
	void *func = entry_point_word->entry_point;
	CODE_TO_FUNCTION_POINTER(func);
	((unwind_native_frames_func_type)func)(quot,to);
}

cell factor_vm::get_fpu_state()
{
	tagged<word> entry_point_word(special_objects[GET_FPU_STATE_WORD]);
	void *func = entry_point_word->entry_point;
	CODE_TO_FUNCTION_POINTER(func);
	return ((get_fpu_state_func_type)func)();
}

void factor_vm::set_fpu_state(cell state)
{
	tagged<word> entry_point_word(special_objects[SET_FPU_STATE_WORD]);
	void *func = entry_point_word->entry_point;
	CODE_TO_FUNCTION_POINTER(func);
	((set_fpu_state_func_type)func)(state);
}

}
