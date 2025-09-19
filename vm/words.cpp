#include "master.hpp"

namespace factor {

// Compile a word definition with the non-optimizing compiler.
// Allocates memory
void factor_vm::jit_compile_word(cell word_, cell def_, bool relocating) {
  data_root<word> word(word_, this);
  data_root<quotation> def(def_, this);

  // Refuse to compile this word more than once, because quot_compiled_p()
  // depends on the identity of its code block
  if (word->entry_point &&
      word.value() == special_objects[LAZY_JIT_COMPILE_WORD])
    return;

  code_block* compiled =
      jit_compile_quotation(word.value(), def.value(), relocating);
  word->entry_point = compiled->entry_point();

  if (to_boolean(word->pic_def))
    jit_compile_quotation(word->pic_def, relocating);
  if (to_boolean(word->pic_tail_def))
    jit_compile_quotation(word->pic_tail_def, relocating);
}

// Allocates memory
word* factor_vm::allot_word(cell name_, cell vocab_, cell hashcode_) {
  data_root<object> vocab(vocab_, this);
  data_root<object> name(name_, this);

  data_root<word> new_word(allot<word>(sizeof(word)), this);

  new_word->hashcode = hashcode_;
  new_word->vocabulary = vocab.value();
  new_word->name = name.value();
  new_word->def = special_objects[OBJ_UNDEFINED];
  new_word->props = false_object;
  new_word->pic_def = false_object;
  new_word->pic_tail_def = false_object;
  new_word->subprimitive = false_object;
  new_word->entry_point = 0;

  jit_compile_word(new_word.value(), new_word->def, true);

  return new_word.untagged();
}

// (word) ( name vocabulary hashcode -- word )
// Allocates memory
void factor_vm::primitive_word() {
  cell hashcode = ctx->pop();
  cell vocab = ctx->pop();
  cell name = ctx->pop();
  ctx->push(tag<word>(allot_word(name, vocab, hashcode)));
}

// word-code ( word -- start end )
// Allocates memory (from_unsigned_cell allocates)
void factor_vm::primitive_word_code() {
  data_root<word> w(ctx->pop(), this);
  check_tagged(w);

  ctx->push(from_unsigned_cell(w->entry_point));
  ctx->push(from_unsigned_cell(cell_from_ptr(w->code()) + w->code()->size()));
}

void factor_vm::primitive_word_optimized_p() {
  word* w = untag_check<word>(ctx->peek());
  cell t = w->code()->type();
  ctx->replace(tag_boolean(t == CODE_BLOCK_OPTIMIZED));
}

// Allocates memory
void factor_vm::primitive_wrapper() {
  wrapper* new_wrapper = allot<wrapper>(sizeof(wrapper));
  new_wrapper->object = ctx->peek();
  ctx->replace(tag<wrapper>(new_wrapper));
}

}
