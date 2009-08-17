#include "master.hpp"

namespace factor
{

word *factorvm::allot_word(cell vocab_, cell name_)
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

word *allot_word(cell vocab_, cell name_)
{
	return vm->allot_word(vocab_,name_);
}

/* <word> ( name vocabulary -- word ) */
inline void factorvm::vmprim_word()
{
	cell vocab = dpop();
	cell name = dpop();
	dpush(tag<word>(allot_word(vocab,name)));
}

PRIMITIVE(word)
{
	PRIMITIVE_GETVM()->vmprim_word();
}

/* word-xt ( word -- start end ) */
inline void factorvm::vmprim_word_xt()
{
	word *w = untag_check<word>(dpop());
	code_block *code = (profiling_p ? w->profiling : w->code);
	dpush(allot_cell((cell)code->xt()));
	dpush(allot_cell((cell)code + code->size));
}

PRIMITIVE(word_xt)
{
	PRIMITIVE_GETVM()->vmprim_word_xt();
}

/* Allocates memory */
void factorvm::update_word_xt(cell w_)
{
	gc_root<word> w(w_,this);

	if(profiling_p)
	{
		if(!w->profiling)
			w->profiling = compile_profiling_stub(w.value());

		w->xt = w->profiling->xt();
	}
	else
		w->xt = w->code->xt();
}

void update_word_xt(cell w_)
{
	return vm->update_word_xt(w_);
}

inline void factorvm::vmprim_optimized_p()
{
	drepl(tag_boolean(word_optimized_p(untag_check<word>(dpeek()))));
}

PRIMITIVE(optimized_p)
{
	PRIMITIVE_GETVM()->vmprim_optimized_p();
}

inline void factorvm::vmprim_wrapper()
{
	wrapper *new_wrapper = allot<wrapper>(sizeof(wrapper));
	new_wrapper->object = dpeek();
	drepl(tag<wrapper>(new_wrapper));
}

PRIMITIVE(wrapper)
{
	PRIMITIVE_GETVM()->vmprim_wrapper();
}

}
