#include "master.hpp"

namespace factor
{

void factor_vm::init_counting_profiler()
{
	counting_profiler_p = false;
}

/* Allocates memory */
code_block *factor_vm::compile_counting_profiler_stub(cell word_)
{
	data_root<word> word(word_,this);

	jit jit(code_block_counting_profiler,word.value(),this);
	jit.emit_with_literal(special_objects[JIT_PROFILING],word.value());

	return jit.to_code_block();
}

/* Allocates memory */
void factor_vm::set_counting_profiler(bool counting_profiler)
{
	if(counting_profiler == counting_profiler_p)
		return;

	/* Push everything to tenured space so that we can heap scan
	and allocate counting_profiler blocks if necessary */
	primitive_full_gc();

	data_root<array> words(find_all_words(),this);

	counting_profiler_p = counting_profiler;

	cell length = array_capacity(words.untagged());
	for(cell i = 0; i < length; i++)
	{
		tagged<word> word(array_nth(words.untagged(),i));

		/* Note: can't do w->counting_profiler = ... since LHS evaluates
		before RHS, and if RHS does a GC, we will have an
		invalid pointer on the LHS */
		if(counting_profiler)
		{
			if(!word->counting_profiler)
			{
				code_block *counting_profiler_block = compile_counting_profiler_stub(word.value());
				word->counting_profiler = counting_profiler_block;
			}

			word->counter = tag_fixnum(0);
		}

		update_word_entry_point(word.untagged());
	}

	update_code_heap_words(false);
}

void factor_vm::primitive_counting_profiler()
{
	set_counting_profiler(to_boolean(ctx->pop()));
}

}
