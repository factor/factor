#include "master.hpp"

bool profiling_p;

void init_profiler(void)
{
	profiling_p = false;
}

/* Allocates memory */
F_CODE_BLOCK *compile_profiling_stub(CELL word_)
{
	gc_root<F_WORD> word(word_);

	jit jit(WORD_TYPE,word.value());
	jit.emit_with(userenv[JIT_PROFILING],word.value());

	return jit.code_block();
}

/* Allocates memory */
static void set_profiling(bool profiling)
{
	if(profiling == profiling_p)
		return;

	profiling_p = profiling;

	/* Push everything to tenured space so that we can heap scan
	and allocate profiling blocks if necessary */
	gc();

	gc_root<F_ARRAY> words(find_all_words());

	CELL i;
	CELL length = array_capacity(words.untagged());
	for(i = 0; i < length; i++)
	{
		tagged<F_WORD> word(array_nth(words.untagged(),i));
		if(profiling)
			word->counter = tag_fixnum(0);
		update_word_xt(word.value());
	}

	/* Update XTs in code heap */
	iterate_code_heap(relocate_code_block);
}

PRIMITIVE(profiling)
{
	set_profiling(to_boolean(dpop()));
}
