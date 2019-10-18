#include "master.h"

bool profiling_p(void)
{
	return to_boolean(userenv[PROFILING_ENV]);
}

F_FIXNUM profiler_prologue(void)
{
	return to_fixnum(userenv[PROFILER_PROLOGUE_ENV]);
}

void profiling_word(F_WORD *word)
{
	/* If we just enabled the profiler, reset call count */
	if(profiling_p())
		word->counter = tag_fixnum(0);

	if(word->compiledp == F)
	{
		if(type_of(word->def) == QUOTATION_TYPE)
			word->xt = default_word_xt(word);
	}
	else
		set_word_xt(word,word->code);
}

void set_profiling(bool profiling)
{
	if(profiling == profiling_p())
		return;

	userenv[PROFILING_ENV] = tag_boolean(profiling);

	/* Push everything to tenured space so that we can heap scan */
	data_gc();

	/* Step 1 - Update word XTs and saved callstack objects */
	begin_scan();

	CELL obj;
	while((obj = next_object()) != F)
	{
		if(type_of(obj) == WORD_TYPE)
			profiling_word(untag_object(obj));
	}

	gc_off = false; /* end heap scan */

	/* Step 2 - Update XTs in code heap */
	iterate_code_heap(relocate_code_block);

	/* Step 3 - flush instruction cache */
	flush_icache(code_heap.segment->start,code_heap.segment->size);
}

DEFINE_PRIMITIVE(profiling)
{
	set_profiling(to_boolean(dpop()));
}
