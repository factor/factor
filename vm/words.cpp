#include "master.hpp"

namespace factor
{

word *factor_vm::allot_word(cell name_, cell vocab_, cell hashcode_)
{
	data_root<object> vocab(vocab_,this);
	data_root<object> name(name_,this);

	data_root<word> new_word(allot<word>(sizeof(word)),this);

	new_word->hashcode = hashcode_;
	new_word->vocabulary = vocab.value();
	new_word->name = name.value();
	new_word->def = special_objects[OBJ_UNDEFINED];
	new_word->props = false_object;
	new_word->counter = tag_fixnum(0);
	new_word->pic_def = false_object;
	new_word->pic_tail_def = false_object;
	new_word->subprimitive = false_object;
	new_word->profiling = NULL;
	new_word->code = NULL;

	jit_compile_word(new_word.value(),new_word->def,true);
	if(profiling_p)
	{
		code_block *profiling_block = compile_profiling_stub(new_word.value());
		new_word->profiling = profiling_block;
		initialize_code_block(new_word->profiling);
	}

	update_word_xt(new_word.untagged());

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
	data_root<word> w(dpop(),this);
	w.untag_check(this);

	if(profiling_p)
	{
		dpush(allot_cell((cell)w->profiling->xt()));
		dpush(allot_cell((cell)w->profiling + w->profiling->size()));
	}
	else
	{
		dpush(allot_cell((cell)w->code->xt()));
		dpush(allot_cell((cell)w->code + w->code->size()));
	}
}

void factor_vm::update_word_xt(word *w)
{
	if(profiling_p && w->profiling)
		w->xt = w->profiling->xt();
	else
		w->xt = w->code->xt();
}

void factor_vm::primitive_optimized_p()
{
	word *w = untag_check<word>(dpeek());
	drepl(tag_boolean(w->code->optimized_p()));
}

void factor_vm::primitive_wrapper()
{
	wrapper *new_wrapper = allot<wrapper>(sizeof(wrapper));
	new_wrapper->object = dpeek();
	drepl(tag<wrapper>(new_wrapper));
}

}
