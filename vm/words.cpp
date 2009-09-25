#include "master.hpp"

namespace factor
{

word *factor_vm::allot_word(cell vocab_, cell name_)
{
	gc_root<object> vocab(vocab_,this);
	gc_root<object> name(name_,this);

	gc_root<word> new_word(allot<word>(sizeof(word)),this);

	new_word->hashcode = tag_fixnum((rand() << 16) ^ rand());
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

/* <word> ( name vocabulary -- word ) */
inline void factor_vm::primitive_word()
{
	cell vocab = dpop();
	cell name = dpop();
	dpush(tag<word>(allot_word(vocab,name)));
}

PRIMITIVE_FORWARD(word)

/* word-xt ( word -- start end ) */
inline void factor_vm::primitive_word_xt()
{
	word *w = untag_check<word>(dpop());
	code_block *code = (profiling_p ? w->profiling : w->code);
	dpush(allot_cell((cell)code->xt()));
	dpush(allot_cell((cell)code + code->size));
}

PRIMITIVE_FORWARD(word_xt)

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

inline void factor_vm::primitive_optimized_p()
{
	drepl(tag_boolean(word_optimized_p(untag_check<word>(dpeek()))));
}

PRIMITIVE_FORWARD(optimized_p)

inline void factor_vm::primitive_wrapper()
{
	wrapper *new_wrapper = allot<wrapper>(sizeof(wrapper));
	new_wrapper->object = dpeek();
	drepl(tag<wrapper>(new_wrapper));
}

PRIMITIVE_FORWARD(wrapper)

}
