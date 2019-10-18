#include "master.hpp"

namespace factor
{

/* Compile a word definition with the non-optimizing compiler. Allocates memory */
void factor_vm::jit_compile_word(cell word_, cell def_, bool relocating)
{
	data_root<word> word(word_,this);
	data_root<quotation> def(def_,this);

	/* Refuse to compile this word more than once, because quot_compiled_p()
	depends on the identity of its code block */
	if(word->entry_point && word.value() == special_objects[LAZY_JIT_COMPILE_WORD])
		return;

	code_block *compiled = jit_compile_quot(word.value(),def.value(),relocating);
	word->entry_point = compiled->entry_point();

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

		if(!word->entry_point || !word->code()->optimized_p())
			jit_compile_word(word.value(),word->def,false);
	}
}

/* Allocates memory */
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
	new_word->pic_def = false_object;
	new_word->pic_tail_def = false_object;
	new_word->subprimitive = false_object;
	new_word->entry_point = NULL;

	jit_compile_word(new_word.value(),new_word->def,true);

	return new_word.untagged();
}

/* Allocates memory */
/* (word) ( name vocabulary hashcode -- word ) */
void factor_vm::primitive_word()
{
	cell hashcode = ctx->pop();
	cell vocab = ctx->pop();
	cell name = ctx->pop();
	ctx->push(tag<word>(allot_word(name,vocab,hashcode)));
}

/* Allocates memory (from_unsigned_cell allocates) */
/* word-code ( word -- start end ) */
void factor_vm::primitive_word_code()
{
	data_root<word> w(ctx->pop(),this);
	w.untag_check(this);

	ctx->push(from_unsigned_cell((cell)w->entry_point));
	ctx->push(from_unsigned_cell((cell)w->code() + w->code()->size()));
}

void factor_vm::primitive_optimized_p()
{
	word *w = untag_check<word>(ctx->peek());
	ctx->replace(tag_boolean(w->code()->optimized_p()));
}

/* Allocates memory */
void factor_vm::primitive_wrapper()
{
	wrapper *new_wrapper = allot<wrapper>(sizeof(wrapper));
	new_wrapper->object = ctx->peek();
	ctx->replace(tag<wrapper>(new_wrapper));
}

}
