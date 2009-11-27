#include "master.hpp"

namespace factor
{

void factor_vm::init_profiler()
{
	profiling_p = false;
}

/* Allocates memory */
code_block *factor_vm::compile_profiling_stub(cell word_)
{
	data_root<word> word(word_,this);

	jit jit(code_block_profiling,word.value(),this);
	jit.emit_with(special_objects[JIT_PROFILING],word.value());

	return jit.to_code_block();
}

/* Allocates memory */
void factor_vm::set_profiling(bool profiling)
{
	if(profiling == profiling_p)
		return;

	/* Push everything to tenured space so that we can heap scan
	and allocate profiling blocks if necessary */
	primitive_full_gc();

	data_root<array> words(find_all_words(),this);

	profiling_p = profiling;

	cell length = array_capacity(words.untagged());
	for(cell i = 0; i < length; i++)
	{
		tagged<word> word(array_nth(words.untagged(),i));

		/* Note: can't do w->profiling = ... since LHS evaluates
		before RHS, and if RHS does a GC, we will have an
		invalid pointer on the LHS */
		if(profiling)
		{
			if(!word->profiling)
			{
				code_block *profiling_block = compile_profiling_stub(word.value());
				word->profiling = profiling_block;
			}

			word->counter = tag_fixnum(0);
		}

		update_word_xt(word.untagged());
	}

	update_code_heap_words();
}

void factor_vm::primitive_profiling()
{
	set_profiling(to_boolean(dpop()));
}

}
