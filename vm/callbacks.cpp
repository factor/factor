#include "master.hpp"

namespace factor {

bool return_takes_param_p() {
#if defined(FACTOR_X86) || defined(FACTOR_AMD64)
  return true;
#else
  return false;
#endif
}

callback_heap::callback_heap(cell size, factor_vm* parent) {
  seg = std::make_unique<segment>(size, true);
  allocator = std::make_unique<free_list_allocator<code_block>>(size, seg->start);
  this->parent = parent;

}

callback_heap::~callback_heap() {
  // unique_ptr automatically handles deletion
}

instruction_operand callback_heap::callback_operand(code_block* stub,
                                                    cell index) {
  tagged<array> code_template(parent->special_objects[CALLBACK_STUB]);
  tagged<byte_array> relocation_template(
      array_nth(code_template.untagged(), 0));

  relocation_entry entry(relocation_template->data<relocation_entry>()[index]);
  return instruction_operand(entry, stub, 0);
}

void callback_heap::store_callback_operand(code_block* stub, cell index,
                                           cell value) {
  instruction_operand op = callback_operand(stub, index);
  op.store_value(value);
}

void callback_heap::update(code_block* stub) {
  word* w = untag<word>(stub->owner);
#ifdef FACTOR_ARM64
  store_callback_operand(stub, 6, w->entry_point);
#else
  store_callback_operand(stub, 1, w->entry_point);
#endif
  stub->flush_icache();
}

code_block* callback_heap::add(cell owner, cell return_rewind) {
  // code_template is a 2-tuple where the first element contains the
  // relocations and the second a byte array of compiled assembly
  // code. The code assumes that there are four relocations on x86 and
  // three on ppc.
  tagged<array> code_template(parent->special_objects[CALLBACK_STUB]);
  tagged<byte_array> insns(array_nth(code_template.untagged(), 1));
  cell size = array_capacity(insns.untagged());

  cell bump = align(size + sizeof(code_block), data_alignment);
  code_block* stub = allocator->allot(bump);
  if (!stub) {
    parent->general_error(ERROR_CALLBACK_SPACE_OVERFLOW,
                          false_object,
                          false_object);
  }
  stub->header = bump & ~7;
  stub->owner = owner;
  stub->parameters = false_object;
  stub->relocation = false_object;

  memcpy((void*)stub->entry_point(), insns->data<void>(), size);

  // Store VM pointer in two relocations.
  store_callback_operand(stub, 0, (cell)parent);
#ifdef FACTOR_ARM64
  store_callback_operand(stub, 1, parent->code->safepoint_page);
  store_callback_operand(stub, 2, (cell)&parent->dispatch_stats.megamorphic_cache_hits);
  store_callback_operand(stub, 3, (cell)&factor::inline_cache_miss);
  store_callback_operand(stub, 4, parent->cards_offset);
  store_callback_operand(stub, 5, parent->decks_offset);
#else
  store_callback_operand(stub, 2, (cell)parent);
#endif

  // On x86, the RET instruction takes an argument which depends on
  // the callback's calling convention
  if (return_takes_param_p())
    store_callback_operand(stub, 3, return_rewind);

  update(stub);
  return stub;
}

// Allocates memory (add(), allot_alien())
void factor_vm::primitive_callback() {
  cell return_rewind = to_cell(ctx->pop());
  tagged<word> w(ctx->pop());
  check_tagged(w);

  cell func = callbacks->add(w.value(), return_rewind)->entry_point();
  CODE_TO_FUNCTION_POINTER_CALLBACK(this, func);
  ctx->push(allot_alien(func));
}

void factor_vm::primitive_free_callback() {
  void* entry_point = alien_offset(ctx->pop());
  code_block* stub = (code_block*)entry_point - 1;
  callbacks->allocator->free(stub);
}

// Allocates memory
void factor_vm::primitive_callback_room() {
  allocator_room room = callbacks->allocator->as_allocator_room();
  ctx->push(tag<byte_array>(byte_array_from_value(&room)));
}

}
