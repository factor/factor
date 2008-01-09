#include "master.h"

/* Allocates memory */
F_COMPILED *compile_profiling_stub(F_WORD *word)
{
	CELL literals = allot_array_1(tag_object(word));
	REGISTER_ROOT(literals);

	F_ARRAY *quadruple = untag_object(userenv[JIT_PROFILING]);

	CELL code = array_nth(quadruple,0);
	REGISTER_ROOT(code);

	CELL rel_type = allot_cell(to_fixnum(array_nth(quadruple,2))
		| (to_fixnum(array_nth(quadruple,1)) << 8));
	CELL rel_offset = array_nth(quadruple,3) * compiled_code_format();

	CELL relocation = allot_array_2(rel_type,rel_offset);

	UNREGISTER_ROOT(code);
	UNREGISTER_ROOT(literals);

	return add_compiled_block(
		WORD_TYPE,
		untag_object(code),
		NULL, /* no labels */
		untag_object(relocation),
		NULL, /* no words */
		untag_object(literals));
}

/* Allocates memory */
void update_word_xt(F_WORD *word)
{
	/* If we just enabled the profiler, reset call count */
	if(profiling_p)
	{
		word->counter = tag_fixnum(0);

		if(!word->profiling)
		{
			REGISTER_UNTAGGED(word);
			F_COMPILED *profiling = compile_profiling_stub(word);
			UNREGISTER_UNTAGGED(word);
			word->profiling = profiling;
		}

		word->xt = (XT)(word->profiling + 1);
	}
	else
		word->xt = (XT)(word->code + 1);
}

void set_profiling(bool profiling)
{
	if(profiling == profiling_p)
		return;

	profiling_p = profiling;

	/* Push everything to tenured space so that we can heap scan,
	also code GC so that we can allocate profiling blocks if
	necessary */
	code_gc();

	/* Update word XTs and saved callstack objects */
	begin_scan();

	CELL obj;
	while((obj = next_object()) != F)
	{
		if(type_of(obj) == WORD_TYPE)
			update_word_xt(untag_object(obj));
	}

	gc_off = false; /* end heap scan */

	/* Update XTs in code heap */
	iterate_code_heap(relocate_code_block);
}

DEFINE_PRIMITIVE(profiling)
{
	set_profiling(to_boolean(dpop()));
}
