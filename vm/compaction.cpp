#include "master.hpp"

namespace factor {

struct compaction_fixup {
  static const bool translated_code_block_map = false;

  mark_bits* data_forwarding_map;
  mark_bits* code_forwarding_map;
  const object** data_finger;
  const code_block** code_finger;

  compaction_fixup(mark_bits* data_forwarding_map,
                   mark_bits* code_forwarding_map,
                   const object** data_finger,
                   const code_block** code_finger)
      : data_forwarding_map(data_forwarding_map),
        code_forwarding_map(code_forwarding_map),
        data_finger(data_finger),
        code_finger(code_finger) {}

  object* fixup_data(object* obj) {
    return (object*)data_forwarding_map->forward_block((cell)obj);
  }

  code_block* fixup_code(code_block* compiled) {
    return (code_block*)code_forwarding_map->forward_block((cell)compiled);
  }

  object* translate_data(const object* obj) {
    if (obj < *data_finger)
      return fixup_data((object*)obj);
    return (object*)obj;
  }

  code_block* translate_code(const code_block* compiled) {
    if (compiled < *code_finger)
      return fixup_code((code_block*)compiled);
    return (code_block*)compiled;
  }

  cell size(object* obj) {
    if (data_forwarding_map->marked_p((cell)obj))
      return obj->size(*this);
    return data_forwarding_map->unmarked_block_size((cell)obj);
  }

  cell size(code_block* compiled) {
    if (code_forwarding_map->marked_p((cell)compiled))
      return compiled->size(*this);
    return code_forwarding_map->unmarked_block_size((cell)compiled);
  }
};

// After a compaction, invalidate any code heap roots which are not
// marked, and also slide the valid roots up so that call sites can be updated
// correctly in case an inline cache compilation triggered compaction.
void factor_vm::update_code_roots_for_compaction() {

  mark_bits* state = &code->allocator->state;

  for (auto* root : code_roots) {
    cell block = root->value & (~data_alignment + 1);

    // Offset of return address within 16-byte allocation line
    cell offset = root->value - block;

    if (root->valid && state->marked_p(block)) {
      block = state->forward_block(block);
      root->value = block + offset;
    } else
      root->valid = false;
  }
}

// Compact data and code heaps
void factor_vm::collect_compact_impl() {
  gc_event* event = current_gc->event.get();

#ifdef FACTOR_DEBUG
  code->verify_all_blocks_set();
#endif

  if (event)
    event->reset_timer();

  tenured_space* tenured = data->tenured.get();
  mark_bits* data_forwarding_map = &tenured->state;
  mark_bits* code_forwarding_map = &code->allocator->state;

  // Figure out where blocks are going to go
  data_forwarding_map->compute_forwarding();
  code_forwarding_map->compute_forwarding();

  const object* data_finger = (object*)tenured->start;
  const code_block* code_finger = (code_block*)code->allocator->start;

  {
    compaction_fixup fixup(data_forwarding_map, code_forwarding_map,
                           &data_finger, &code_finger);
    slot_visitor<compaction_fixup> forwarder(this, fixup);

    forwarder.visit_uninitialized_code_blocks();

    // Object start offsets get recomputed by the object_compaction_updater
    data->tenured.get()->starts.clear_object_start_offsets();

    // Slide everything in tenured space up, and update data and code heap
    // pointers inside objects.
    auto compact_object_func = [&](object* old_addr, object* new_addr, cell size) {
      (void)old_addr;
      (void)size;
      forwarder.visit_slots(new_addr);
      forwarder.visit_object_code_block(new_addr);
      tenured->starts.record_object_start_offset(new_addr);
    };
    tenured->compact(compact_object_func, fixup, &data_finger);

    // Slide everything in the code heap up, and update data and code heap
    // pointers inside code blocks.
    auto compact_code_func = [&](code_block* old_addr,
                                 code_block* new_addr,
                                 cell size) {
      (void)size;
      forwarder.visit_code_block_objects(new_addr);
      cell old_entry_point = old_addr->entry_point();
      forwarder.visit_instruction_operands(new_addr, old_entry_point);
    };
    code->allocator->compact(compact_code_func, fixup, &code_finger);

    forwarder.visit_all_roots();
    forwarder.visit_context_code_blocks();
  }

  update_code_roots_for_compaction();

  // Each callback has a relocation with a pointer to a code block in
  // the code heap. Since the code heap has now been compacted, those
  // pointers are invalid and we need to update them.
  auto callback_updater = [&](code_block* stub, cell size) {
    (void)size;
    callbacks->update(stub);
  };
  callbacks->allocator->iterate(callback_updater, no_fixup());

  code->initialize_all_blocks_set();

  if (event)
    event->ended_phase(PHASE_DATA_COMPACTION);
}

void factor_vm::collect_compact() {
  collect_mark_impl();
  collect_compact_impl();

  // Compaction did not free up enough memory. Grow the data heap.
  if (data->high_fragmentation_p()) {
    set_current_gc_op(COLLECT_GROWING_DATA_HEAP_OP);
    collect_growing_data_heap(0);
  }

  code->flush_icache();
}

void factor_vm::collect_growing_data_heap(cell requested_size) {
  // Grow the data heap and copy all live objects to the new heap.
  auto new_data = data->grow(&nursery, requested_size);
  set_data_heap(std::move(new_data));
  collect_mark_impl();
  collect_compact_impl();
  code->flush_icache();
}

}
