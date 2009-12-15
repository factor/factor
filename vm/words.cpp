#include "master.hpp"

namespace factor
{

/* Compile a word definition with the non-optimizing compiler. Allocates memory */
void factor_vm::jit_compile_word(cell word_, cell def_, bool relocating)
{
	data_root<word> word(word_,this);
	data_root<quotation> def(def_,this);

	code_block *compiled = jit_compile_quot(word.value(),def.value(),relocating);
	word->code = compiled;

	if(to_boolean(word->pic_def)) jit_compile_quot(word->pic_def,relocating);
	if(to_boolean(word->pic_tail_def)) jit_compile_quot(word->pic_tail_def,relocating);
}

cell factor_vm::find_all_words()
{
	return instances(WORD_TYPE);
}

void factor_vm::compile_all_words()
{
	data_root<array> words(find_all_words(),this);

	cell length = array_capacity(words.untagged());
	for(cell i = 0; i < length; i++)
	{
		data_root<word> word(array_nth(words.untagged(),i),this);

		if(!word->code || !word->code->optimized_p())
			jit_compile_word(word.value(),word->def,false);

		update_word_xt(word.untagged());

	}
}

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
