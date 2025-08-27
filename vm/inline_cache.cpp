#include "master.hpp"

namespace factor {

void factor_vm::deallocate_inline_cache(cell return_address) {
  // Find the call target.
  void* old_entry_point = get_call_target(return_address);
  code_block* old_block = (code_block*)old_entry_point - 1;

  // Free the old PIC since we know its unreachable
  if (old_block->pic_p())
    code->free(old_block);
}

// Figure out what kind of type check the PIC needs based on the methods
// it contains
static cell determine_inline_cache_type(array* cache_entries) {
  for (cell i = 0; i < array_capacity(cache_entries); i += 2) {
    // Is it a tuple layout?
    if (TAG(array_nth(cache_entries, i)) == ARRAY_TYPE) {
      return PIC_TUPLE;
    }
  }
  return PIC_TAG;
}

void factor_vm::update_pic_count(cell type) {
  if (type == PIC_TAG)
    dispatch_stats.pic_tag_count++;
  else
    dispatch_stats.pic_tuple_count++;
}

struct inline_cache_jit : public jit {
  inline_cache_jit(cell generic_word, factor_vm* vm) : jit(generic_word, vm) {}

  void emit_check_and_jump(cell ic_type, cell i, cell klass, cell method);
  void emit_inline_cache(fixnum index, cell generic_word_, cell methods_,
                         cell cache_entries_, bool tail_call_p);
};

void inline_cache_jit::emit_check_and_jump(cell ic_type, cell i,
                                           cell klass, cell method) {
  // Class equal?
  cell check_type = PIC_CHECK_TAG;
  if (TAG(klass) != FIXNUM_TYPE)
      check_type = PIC_CHECK_TUPLE;

  // The tag check can be skipped if it is the first one and we are
  // checking for the fixnum type which is 0. That is because the
  // AND instruction in the PIC_TAG template already sets the zero
  // flag.
  if (!(i == 0 && ic_type == PIC_TAG && klass == 0)) {
    emit_with_literal(parent->special_objects[check_type], klass);
  }

  // Yes? Jump to method
  emit_with_literal(parent->special_objects[PIC_HIT], method);
}

// index: 0 = top of stack, 1 = item underneath, etc
// cache_entries: array of class/method pairs
// Allocates memory
void inline_cache_jit::emit_inline_cache(fixnum index, cell generic_word_,
                                         cell methods_, cell cache_entries_,
                                         bool tail_call_p) {
  data_root<word> generic_word(generic_word_, parent);
  data_root<array> methods(methods_, parent);
  data_root<array> cache_entries(cache_entries_, parent);

  cell ic_type = determine_inline_cache_type(cache_entries.untagged());
  parent->update_pic_count(ic_type);

  // Put the tag of the object, or class of the tuple in a register.
  emit_with_literal(parent->special_objects[PIC_LOAD],
                    tag_fixnum(-index * sizeof(cell)));

  // Generate machine code to determine the object's class.
  emit(parent->special_objects[ic_type]);

  // Generate machine code to check, in turn, if the class is one of the cached
  // entries.
  for (cell i = 0; i < array_capacity(cache_entries.untagged()); i += 2) {
    cell klass = array_nth(cache_entries.untagged(), i);
    cell method = array_nth(cache_entries.untagged(), i + 1);

    emit_check_and_jump(ic_type, i, klass, method);
  }

  // If none of the above conditionals tested true, then execution "falls
  // through" to here.

  // A stack frame is set up, since the inline-cache-miss sub-primitive
  // makes a subroutine call to the VM.
  emit(parent->special_objects[JIT_PROLOG]);

  // The inline-cache-miss sub-primitive call receives enough information to
  // reconstruct the PIC with the new entry.
  push(generic_word.value());
  push(methods.value());
  push(tag_fixnum(index));
  push(cache_entries.value());

  emit_subprimitive(
      parent->special_objects[tail_call_p ? PIC_MISS_TAIL_WORD : PIC_MISS_WORD],
      true,  // tail_call_p
      true); // stack_frame_p
}

// Allocates memory
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

// The cache_entries parameter is empty (on cold call site) or has entries
// (on cache miss). Called from assembly with the actual return address.
// Compilation of the inline cache may trigger a GC, which may trigger a
// compaction;
// also, the block containing the return address may now be dead. Use a
// code_root to take care of the details.
// Allocates memory
cell factor_vm::inline_cache_miss(cell return_address_) {
  code_root return_address(return_address_, this);
  bool tail_call_site = tail_call_site_p(return_address.value);

#ifdef PIC_DEBUG
  FACTOR_PRINT("Inline cache miss at "
               << (tail_call_site ? "tail" : "non-tail")
               << " call site 0x" << std::hex << return_address.value
               << std::dec);
  print_callstack();
#endif

  data_root<array> cache_entries(ctx->pop(), this);
  fixnum index = untag_fixnum(ctx->pop());
  data_root<array> methods(ctx->pop(), this);
  data_root<word> generic_word(ctx->pop(), this);
  
  // Bounds check for stack access
  cell* stack_ptr = (cell*)ctx->datastack;
  cell* stack_base = (cell*)ctx->datastack_seg->start;
  if (index < 0 || stack_ptr - index < stack_base) {
    general_error(ERROR_DATASTACK_UNDERFLOW, false_object, false_object);
  }
  
  data_root<object> object(stack_ptr[-index], this);

  cell pic_size = array_capacity(cache_entries.untagged()) / 2;

  update_pic_transitions(pic_size);

  cell xt = generic_word->entry_point;
  if (pic_size < max_pic_size) {
    cell klass = object_class(object.value());
    cell method = lookup_method(object.value(), methods.value());

    data_root<array> new_cache_entries(
        add_inline_cache_entry(cache_entries.value(), klass, method), this);

    inline_cache_jit jit(generic_word.value(), this);
    jit.emit_inline_cache(index, generic_word.value(), methods.value(),
                          new_cache_entries.value(), tail_call_site);
    code_block* code = jit.to_code_block(CODE_BLOCK_PIC, JIT_FRAME_SIZE);
    initialize_code_block(code);
    xt = code->entry_point();
  }

  // Install the new stub.
  if (return_address.valid) {
    // Since each PIC is only referenced from a single call site,
    // if the old call target was a PIC, we can deallocate it immediately,
    // instead of leaving dead PICs around until the next GC.
    deallocate_inline_cache(return_address.value);
    set_call_target(return_address.value, xt);

#ifdef PIC_DEBUG
    FACTOR_PRINT("Updated " << (tail_call_site ? "tail" : "non-tail")
                 << " call site 0x" << std::hex << return_address.value << std::dec
                 << " with 0x" << std::hex << (cell)xt << std::dec);
    print_callstack();
#endif
  }

  return xt;
}

// Allocates memory
VM_C_API cell inline_cache_miss(cell return_address, factor_vm* parent) {
  return parent->inline_cache_miss(return_address);
}

}
