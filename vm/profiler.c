#include "master.h"

/* Allocates memory */
F_COMPILED *compile_profiling_stub(F_WORD *word)
{
	CELL literals = allot_array_1(tag_object(word));
	REGISTER_ROOT(literals);

	F_ARRAY *quadruple = untag_object(userenv[JIT_PROFILING]);

	CELL code = array_nth(quadruple,0);
	REGISTER_ROOT(code);

	F_REL rel;
	rel.type = to_fixnum(array_nth(quadruple,2)) | (to_fixnum(array_nth(quadruple,1)) << 8);
	rel.offset = to_fixnum(array_nth(quadruple,3)) * compiled_code_format();

	F_BYTE_ARRAY *relocation = allot_byte_array(sizeof(F_REL));
	memcpy((void *)BREF(relocation,0),&rel,sizeof(F_REL));

	UNREGISTER_ROOT(code);
	UNREGISTER_ROOT(literals);

	return add_compiled_block(
		WORD_TYPE,
		untag_object(code),
		NULL, /* no labels */
		tag_object(relocation),
		literals);
}

/* Allocates memory */
void update_word_xt(F_WORD *word)
{
	if(profiling_p)
	{
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
