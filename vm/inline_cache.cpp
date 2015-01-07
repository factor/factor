#include "master.hpp"

namespace factor {

void factor_vm::init_inline_caching(int max_size) { max_pic_size = max_size; }

void factor_vm::deallocate_inline_cache(cell return_address) {
  /* Find the call target. */
  void* old_entry_point = get_call_target(return_address);
  code_block* old_block = (code_block*)old_entry_point - 1;

  /* Free the old PIC since we know its unreachable */
  if (old_block->pic_p())
    code->free(old_block);
}

/* Figure out what kind of type check the PIC needs based on the methods
   it contains */
cell factor_vm::determine_inline_cache_type(array* cache_entries) {
  bool seen_tuple = false;

  cell i;
  for (i = 0; i < array_capacity(cache_entries); i += 2) {
    /* Is it a tuple layout? */
    if (TAG(array_nth(cache_entries, i)) == ARRAY_TYPE) {
      seen_tuple = true;
      break;
    }
  }

  return seen_tuple ? PIC_TUPLE : PIC_TAG;
}

void factor_vm::update_pic_count(cell type) {
  if (type == PIC_TAG)
    dispatch_stats.pic_tag_count++;
  else
    dispatch_stats.pic_tuple_count++;
}

struct inline_cache_jit : public jit {
  fixnum index;

  inline_cache_jit(cell generic_word, factor_vm* vm)
      : jit(code_block_pic, generic_word, vm) {}
  ;

  void emit_check(cell klass);
  void compile_inline_cache(fixnum index, cell generic_word_, cell methods_,
                            cell cache_entries_, bool tail_call_p);
};

/* Allocates memory */
void inline_cache_jit::emit_check(cell klass) {
  cell code_template;
  if (TAG(klass) == FIXNUM_TYPE)
    code_template = parent->special_objects[PIC_CHECK_TAG];
  else
    code_template = parent->special_objects[PIC_CHECK_TUPLE];

  emit_with_literal(code_template, klass);
}

/* index: 0 = top of stack, 1 = item underneath, etc
   cache_entries: array of class/method pairs */
/* Allocates memory */
void inline_cache_jit::compile_inline_cache(fixnum index, cell generic_word_,
                                            cell methods_, cell cache_entries_,
                                            bool tail_call_p) {
  data_root<word> generic_word(generic_word_, parent);
  data_root<array> methods(methods_, parent);
  data_root<array> cache_entries(cache_entries_, parent);

  cell inline_cache_type =
      parent->determine_inline_cache_type(cache_entries.untagged());
  parent->update_pic_count(inline_cache_type);

  /* Generate machine code to determine the object's class. */
  emit_with_literal(parent->special_objects[PIC_LOAD],
                    tag_fixnum(-index * sizeof(cell)));
  emit(parent->special_objects[inline_cache_type]);

  /* Generate machine code to check, in turn, if the class is one of the cached
   * entries. */
  cell i;
  for (i = 0; i < array_capacity(cache_entries.untagged()); i += 2) {
    /* Class equal? */
    cell klass = array_nth(cache_entries.untagged(), i);
    emit_check(klass);

    /* Yes? Jump to method */
    cell method = array_nth(cache_entries.untagged(), i + 1);
    emit_with_literal(parent->special_objects[PIC_HIT], method);
  }

  /* If none of the above conditionals tested true, then execution "falls
     through" to here. */

  /* A stack frame is set up, since the inline-cache-miss sub-primitive
     makes a subroutine call to the VM. */
  emit(parent->special_objects[JIT_PROLOG]);

  /* The inline-cache-miss sub-primitive call receives enough information to
     reconstruct the PIC with the new entry. */
  push(generic_word.value());
  push(methods.value());
  push(tag_fixnum(index));
  push(cache_entries.value());

  emit_subprimitive(
      parent->special_objects[tail_call_p ? PIC_MISS_TAIL_WORD : PIC_MISS_WORD],
      true,  /* tail_call_p */
      true); /* stack_frame_p */
}

/* Allocates memory */
code_block* factor_vm::compile_inline_cache(fixnum index, cell generic_word_,
                                            cell methods_, cell cache_entries_,
                                            bool tail_call_p) {
  data_root<word> generic_word(generic_word_, this);
  data_root<array> methods(methods_, this);
  data_root<array> cache_entries(cache_entries_, this);

  inline_cache_jit jit(generic_word.value(), this);
  jit.compile_inline_cache(index, generic_word.value(), methods.value(),
                           cache_entries.value(), tail_call_p);
  code_block* code = jit.to_code_block(JIT_FRAME_SIZE);
  initialize_code_block(code);
  return code;
}

cell factor_vm::inline_cache_size(cell cache_entries) {
  return array_capacity(untag_check<array>(cache_entries)) / 2;
}

/* Allocates memory */
cell factor_vm::add_inline_cache_entry(cell cache_entries_, cell klass_,
                                       cell method_) {
  data_root<array> cache_entries(cache_entries_, this);
  data_root<object> klass(klass_, this);
  data_root<word> method(method_, this);

  cell pic_size = array_capacity(cache_entries.untagged());
  data_root<array> new_cache_entries(
      reallot_array(cache_entries.untagged(), pic_size + 2), this);
  set_array_nth(new_cache_entries.untagged(), pic_size, klass.value());
  set_array_nth(new_cache_entries.untagged(), pic_size + 1, method.value());
  return new_cache_entries.value();
}

void factor_vm::update_pic_transitions(cell pic_size) {
  if (pic_size == max_pic_size)
    dispatch_stats.pic_to_mega_transitions++;
  else if (pic_size == 0)
    dispatch_stats.cold_call_to_ic_transitions++;
  else if (pic_size == 1)
    dispatch_stats.ic_to_pic_transitions++;
}

/* The cache_entries parameter is empty (on cold call site) or has entries
   (on cache miss). Called from assembly with the actual return address.
   Compilation of the inline cache may trigger a GC, which may trigger a
   compaction;
   also, the block containing the return address may now be dead. Use a
   code_root to take care of the details. */
/* Allocates memory */
cell factor_vm::inline_cache_miss(cell return_address_) {
  code_root return_address(return_address_, this);
  bool tail_call_site = tail_call_site_p(return_address.value);

#ifdef PIC_DEBUG
  std::cout << "Inline cache miss at " << (tail_call_site ? "tail" : "non-tail")
            << " call site 0x" << std::hex << return_address.value << std::dec
            << std::endl;
  print_callstack();
#endif

  data_root<array> cache_entries(ctx->pop(), this);
  fixnum index = untag_fixnum(ctx->pop());
  data_root<array> methods(ctx->pop(), this);
  data_root<word> generic_word(ctx->pop(), this);
  data_root<object> object(((cell*)ctx->datastack)[-index], this);

  cell pic_size = inline_cache_size(cache_entries.value());

  update_pic_transitions(pic_size);

  cell xt;

  if (pic_size >= max_pic_size)
    xt = generic_word->entry_point;
  else {
    cell klass = object_class(object.value());
    cell method = lookup_method(object.value(), methods.value());

    data_root<array> new_cache_entries(
        add_inline_cache_entry(cache_entries.value(), klass, method), this);

    xt = compile_inline_cache(index, generic_word.value(), methods.value(),
                              new_cache_entries.value(), tail_call_site)
        ->entry_point();
  }

  /* Install the new stub. */
  if (return_address.valid) {
    /* Since each PIC is only referenced from a single call site,
       if the old call target was a PIC, we can deallocate it immediately,
       instead of leaving dead PICs around until the next GC. */
    deallocate_inline_cache(return_address.value);
    set_call_target(return_address.value, xt);

#ifdef PIC_DEBUG
    std::cout << "Updated " << (tail_call_site ? "tail" : "non-tail")
              << " call site 0x" << std::hex << return_address.value << std::dec
              << " with 0x" << std::hex << (cell)xt << std::dec << std::endl;
    print_callstack();
#endif
  }

  return xt;
}

/* Allocates memory */
VM_C_API cell inline_cache_miss(cell return_address, factor_vm* parent) {
  return parent->inline_cache_miss(return_address);
}

}
