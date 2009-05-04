#include "master.hpp"

F_WORD *allot_word(CELL vocab_, CELL name_)
{
	gc_root<F_OBJECT> vocab(vocab_);
	gc_root<F_OBJECT> name(name_);

	gc_root<F_WORD> word(allot<F_WORD>(sizeof(F_WORD)));

	word->hashcode = tag_fixnum((rand() << 16) ^ rand());
	word->vocabulary = vocab.value();
	word->name = name.value();
	word->def = userenv[UNDEFINED_ENV];
	word->props = F;
	word->counter = tag_fixnum(0);
	word->direct_entry_def = F;
	word->subprimitive = F;
	word->profiling = NULL;
	word->code = NULL;

	jit_compile_word(word.value(),word->def,true);
	update_word_xt(word.value());

	if(profiling_p)
		relocate_code_block(word->profiling);

	return word.untagged();
}

/* <word> ( name vocabulary -- word ) */
PRIMITIVE(word)
{
	CELL vocab = dpop();
	CELL name = dpop();
	dpush(tag<F_WORD>(allot_word(vocab,name)));
}

/* word-xt ( word -- start end ) */
PRIMITIVE(word_xt)
{
	F_WORD *word = untag_check<F_WORD>(dpop());
	F_CODE_BLOCK *code = (profiling_p ? word->profiling : word->code);
	dpush(allot_cell((CELL)code + sizeof(F_CODE_BLOCK)));
	dpush(allot_cell((CELL)code + code->block.size));
}

/* Allocates memory */
void update_word_xt(CELL word_)
{
	gc_root<F_WORD> word(word_);

	if(profiling_p)
	{
		if(!word->profiling)
		{
			F_CODE_BLOCK *profiling = compile_profiling_stub(word.value());
			word->profiling = profiling;
		}

		word->xt = (XT)(word->profiling + 1);
	}
	else
		word->xt = (XT)(word->code + 1);
}

PRIMITIVE(optimized_p)
{
	drepl(tag_boolean(word_optimized_p(untag_check<F_WORD>(dpeek()))));
}

PRIMITIVE(wrapper)
{
	F_WRAPPER *wrapper = allot<F_WRAPPER>(sizeof(F_WRAPPER));
	wrapper->object = dpeek();
	drepl(tag<F_WRAPPER>(wrapper));
}
