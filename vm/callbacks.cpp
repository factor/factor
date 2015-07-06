#include "master.hpp"

namespace factor {

callback_heap::callback_heap(cell size, factor_vm* parent) {
  seg = new segment(size, true);
  if (!seg)
    fatal_error("Out of memory in callback_heap constructor", size);
  allocator = new free_list_allocator<code_block>(size, seg->start);
  this->parent = parent;

}

callback_heap::~callback_heap() {
  delete allocator;
  allocator = NULL;
  delete seg;
  seg = NULL;

}

void factor_vm::init_callbacks(cell size) {
  callbacks = new callback_heap(size, this);
}

bool callback_heap::setup_seh_p() {
#if defined(WINDOWS) && defined(FACTOR_X86)
  return true;
#else
  return false;
#endif
}

bool callback_heap::return_takes_param_p() {
#if defined(FACTOR_X86) || defined(FACTOR_AMD64)
  return true;
#else
  return false;
#endif
}

instruction_operand callback_heap::callback_operand(code_block* stub,
                                                    cell index) {
  tagged<array> code_template(parent->special_objects[CALLBACK_STUB]);
  tagged<byte_array> relocation_template(
      array_nth(code_template.untagged(), 0));

  relocation_entry entry(relocation_template->data<relocation_entry>()[index]);
  return instruction_operand(entry, stub, 0);
}

void callback_heap::store_callback_operand(code_block* stub, cell index) {
  parent->store_external_address(callback_operand(stub, index));
}

void callback_heap::store_callback_operand(code_block* stub, cell index,
                                           cell value) {
  callback_operand(stub, index).store_value(value);
}

void callback_heap::update(code_block* stub) {
  store_callback_operand(stub, setup_seh_p() ? 2 : 1,
                         callback_entry_point(stub));
  stub->flush_icache();
}

code_block* callback_heap::add(cell owner, cell return_rewind) {
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

  /* Store VM pointer */
  store_callback_operand(stub, 0, (cell)parent);

  cell index;

  if (setup_seh_p()) {
    store_callback_operand(stub, 1);
    index = 1;
  } else
    index = 0;

  /* Store VM pointer */
  store_callback_operand(stub, index + 2, (cell) parent);

  /* On x86, the RET instruction takes an argument which depends on
     the callback's calling convention */
  if (return_takes_param_p())
    store_callback_operand(stub, index + 3, return_rewind);

  update(stub);

  return stub;
}

void callback_heap::update() {
  auto callback_updater = [&](code_block* stub, cell size) {
    update(stub);
  };
  allocator->iterate(callback_updater);
}

/* Allocates memory (add(), allot_alien())*/
void factor_vm::primitive_callback() {
  cell return_rewind = to_cell(ctx->pop());
  tagged<word> w(ctx->pop());

  w.untag_check(this);

  cell func = callbacks->add(w.value(), return_rewind)->entry_point();
  CODE_TO_FUNCTION_POINTER_CALLBACK(this, func);
  ctx->push(allot_alien((void*)func));
}

void factor_vm::primitive_free_callback() {
  void* entry_point = alien_offset(ctx->pop());
  code_block* stub = (code_block*)entry_point - 1;
  callbacks->allocator->free(stub);
}

/* Allocates memory */
void factor_vm::primitive_callback_room() {
  allocator_room room = callbacks->allocator->as_allocator_room();
  ctx->push(tag<byte_array>(byte_array_from_value(&room)));
}

}
