#include "master.h"

/* Allocates memory */
F_CODE_BLOCK *compile_profiling_stub(CELL word)
{
	REGISTER_ROOT(word);
	F_JIT jit;
	jit_init(&jit,WORD_TYPE,word);
	jit_emit_with(&jit,userenv[JIT_PROFILING],word);
	F_CODE_BLOCK *block = jit_make_code_block(&jit);
	jit_dispose(&jit);
	UNREGISTER_ROOT(word);
	return block;
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

	CELL words = find_all_words();

	REGISTER_ROOT(words);

	CELL i;
	CELL length = array_capacity(untag_object(words));
	for(i = 0; i < length; i++)
	{
		F_WORD *word = untag_word(array_nth(untag_array(words),i));
		if(profiling)
			word->counter = tag_fixnum(0);
		update_word_xt(word);
	}

	UNREGISTER_ROOT(words);

	/* Update XTs in code heap */
	iterate_code_heap(relocate_code_block);
}

void primitive_profiling(void)
{
	set_profiling(to_boolean(dpop()));
}
