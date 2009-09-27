#include "master.hpp"

namespace factor
{

word *factor_vm::allot_word(cell name_, cell vocab_, cell hashcode_)
{
	gc_root<object> vocab(vocab_,this);
	gc_root<object> name(name_,this);

	gc_root<word> new_word(allot<word>(sizeof(word)),this);

	new_word->hashcode = hashcode_;
	new_word->vocabulary = vocab.value();
	new_word->name = name.value();
	new_word->def = userenv[UNDEFINED_ENV];
	new_word->props = F;
	new_word->counter = tag_fixnum(0);
	new_word->pic_def = F;
	new_word->pic_tail_def = F;
	new_word->subprimitive = F;
	new_word->profiling = NULL;
	new_word->code = NULL;

	jit_compile_word(new_word.value(),new_word->def,true);
	update_word_xt(new_word.value());

	if(profiling_p)
		relocate_code_block(new_word->profiling);

	return new_word.untagged();
}

/* (word) ( name vocabulary hashcode -- word ) */
void factor_vm::primitive_word()
{
	cell hashcode = dpop();
	cell vocab = dpop();
	cell name = dpop();
	dpush(tag<word>(allot_word(name,vocab,hashcode)));
}

/* word-xt ( word -- start end ) */
void factor_vm::primitive_word_xt()
{
	gc_root<word> w(dpop(),this);
	w.untag_check(this);

	if(profiling_p)
	{
		dpush(allot_cell((cell)w->profiling->xt()));
		dpush(allot_cell((cell)w->profiling + w->profiling->size));
	}
	else
	{
		dpush(allot_cell((cell)w->code->xt()));
		dpush(allot_cell((cell)w->code + w->code->size));
	}
}

/* Allocates memory */
void factor_vm::update_word_xt(cell w_)
{
	gc_root<word> w(w_,this);

	if(profiling_p)
	{
		if(!w->profiling)
		{
			/* Note: can't do w->profiling = ... since if LHS
			evaluates before RHS, since in that case if RHS does a
			GC, we will have an invalid pointer on the LHS */
			code_block *profiling = compile_profiling_stub(w.value());
			w->profiling = profiling;
		}

		w->xt = w->profiling->xt();
	}
	else
		w->xt = w->code->xt();
}

void factor_vm::primitive_optimized_p()
{
	drepl(tag_boolean(word_optimized_p(untag_check<word>(dpeek()))));
}

void factor_vm::primitive_wrapper()
{
	wrapper *new_wrapper = allot<wrapper>(sizeof(wrapper));
	new_wrapper->object = dpeek();
	drepl(tag<wrapper>(new_wrapper));
}

}
