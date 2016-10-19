#include "master.hpp"

namespace factor {

// Simple code generator used by:
// - quotation compiler (quotations.cpp),
// - megamorphic caches (dispatch.cpp),
// - polymorphic inline caches (inline_cache.cpp)

// Allocates memory (`code` and `relocation` initializers create
// growable_byte_array)
jit::jit(cell owner, factor_vm* vm)
    : owner(owner, vm),
      code(vm),
      relocation(vm),
      parameters(vm),
      literals(vm),
      computing_offset_p(false),
      position(0),
      offset(0),
      parent(vm) {
  fixnum old_count = atomic::fetch_add(&parent->current_jit_count, 1);
  FACTOR_ASSERT(old_count >= 0);
  (void)old_count;
}

jit::~jit() {
  fixnum old_count = atomic::fetch_subtract(&parent->current_jit_count, 1);
  FACTOR_ASSERT(old_count >= 1);
  (void)old_count;
}

// Allocates memory
void jit::emit_relocation(cell relocation_template_) {
  data_root<byte_array> relocation_template(relocation_template_, parent);
  cell capacity =
      array_capacity(relocation_template.untagged()) / sizeof(relocation_entry);
  relocation_entry* relocations = relocation_template->data<relocation_entry>();
  for (cell i = 0; i < capacity; i++) {
    relocation_entry entry = relocations[i];
    relocation_entry new_entry(entry.type(), entry.klass(),
                               entry.offset() + code.count);
    relocation.append_bytes(&new_entry, sizeof(relocation_entry));
  }
}

// Allocates memory
void jit::emit(cell code_template_) {
  data_root<array> code_template(code_template_, parent);

  emit_relocation(array_nth(code_template.untagged(), 0));

  data_root<byte_array> insns(array_nth(code_template.untagged(), 1), parent);

  if (computing_offset_p) {
    cell size = array_capacity(insns.untagged());

    if (offset == 0) {
      position--;
      computing_offset_p = false;
    } else if (offset < size) {
      position++;
      computing_offset_p = false;
    } else
      offset -= size;
  }

  code.append_byte_array(insns.value());
}

// Allocates memory
void jit::emit_with_literal(cell code_template_, cell argument_) {
  data_root<array> code_template(code_template_, parent);
  data_root<object> argument(argument_, parent);
  literal(argument.value());
  emit(code_template.value());
}

// Allocates memory
void jit::emit_with_parameter(cell code_template_, cell argument_) {
  data_root<array> code_template(code_template_, parent);
  data_root<object> argument(argument_, parent);
  parameter(argument.value());
  emit(code_template.value());
}

// Allocates memory
bool jit::emit_subprimitive(cell word_, bool tail_call_p, bool stack_frame_p) {
  data_root<word> word(word_, parent);
  data_root<array> code_template(word->subprimitive, parent);
  parameters.append(untag<array>(array_nth(code_template.untagged(), 0)));
  literals.append(untag<array>(array_nth(code_template.untagged(), 1)));
  emit(array_nth(code_template.untagged(), 2));

  if (array_capacity(code_template.untagged()) == 5) {
    if (tail_call_p) {
      if (stack_frame_p)
        emit(parent->special_objects[JIT_EPILOG]);
      emit(array_nth(code_template.untagged(), 4));
      return true;
    } else
      emit(array_nth(code_template.untagged(), 3));
  }
  return false;
}

// Facility to convert compiled code offsets to quotation offsets.
// Call jit_compute_offset() with the compiled code offset, then emit
// code, and at the end jit->position is the quotation position.
void jit::compute_position(cell offset_) {
  computing_offset_p = true;
  position = 0;
  offset = offset_;
}

// Allocates memory (trim(), add_code_block)
code_block* jit::to_code_block(code_block_type type, cell frame_size) {
  // Emit dummy GC info
  code.grow_bytes(alignment_for(code.count + 4, data_alignment));
  uint32_t dummy_gc_info = 0;
  code.append_bytes(&dummy_gc_info, sizeof(uint32_t));

  code.trim();
  relocation.trim();
  parameters.trim();
  literals.trim();

  return parent->add_code_block(
      type, code.elements.value(), false_object, // no labels
      owner.value(), relocation.elements.value(), parameters.elements.value(),
      literals.elements.value(), frame_size);
}

}
