#include "master.h"

F_WORD *allot_word(CELL vocab, CELL name)
{
	REGISTER_ROOT(vocab);
	REGISTER_ROOT(name);
	F_WORD *word = allot_object(WORD_TYPE,sizeof(F_WORD));
	UNREGISTER_ROOT(name);
	UNREGISTER_ROOT(vocab);

	word->hashcode = tag_fixnum((rand() << 16) ^ rand());
	word->vocabulary = vocab;
	word->name = name;
	word->def = userenv[UNDEFINED_ENV];
	word->props = F;
	word->counter = tag_fixnum(0);
	word->direct_entry_def = F;
	word->subprimitive = F;
	word->profiling = NULL;
	word->code = NULL;

	REGISTER_UNTAGGED(word);
	jit_compile_word(word,word->def,true);
	UNREGISTER_UNTAGGED(word);

	REGISTER_UNTAGGED(word);
	update_word_xt(word);
	UNREGISTER_UNTAGGED(word);

	if(profiling_p)
		relocate_code_block(word->profiling);

	return word;
}

/* <word> ( name vocabulary -- word ) */
void primitive_word(void)
{
	CELL vocab = dpop();
	CELL name = dpop();
	dpush(tag_object(allot_word(vocab,name)));
}

/* word-xt ( word -- start end ) */
void primitive_word_xt(void)
{
	F_WORD *word = untag_word(dpop());
	F_CODE_BLOCK *code = (profiling_p ? word->profiling : word->code);
	dpush(allot_cell((CELL)code + sizeof(F_CODE_BLOCK)));
	dpush(allot_cell((CELL)code + code->block.size));
}

/* Allocates memory */
void update_word_xt(F_WORD *word)
{
	if(profiling_p)
	{
		if(!word->profiling)
		{
			REGISTER_UNTAGGED(word);
			F_CODE_BLOCK *profiling = compile_profiling_stub(tag_object(word));
			UNREGISTER_UNTAGGED(word);
			word->profiling = profiling;
		}

		word->xt = (XT)(word->profiling + 1);
	}
	else
		word->xt = (XT)(word->code + 1);
}

void primitive_optimized_p(void)
{
	drepl(tag_boolean(word_optimized_p(untag_word(dpeek()))));
}

void primitive_wrapper(void)
{
	F_WRAPPER *wrapper = allot_object(WRAPPER_TYPE,sizeof(F_WRAPPER));
	wrapper->object = dpeek();
	drepl(tag_object(wrapper));
}
