#include "master.hpp"

namespace factor {

/* After a sweep, invalidate any code heap roots which are not marked,
   so that if a block makes a tail call to a generic word, and the PIC
   compiler triggers a GC, and the caller block gets GCd as a result,
   the PIC code won't try to overwrite the call site */
void factor_vm::update_code_roots_for_sweep() {
  std::vector<code_root*>::const_iterator iter = code_roots.begin();
  std::vector<code_root*>::const_iterator end = code_roots.end();

  mark_bits* state = &code->allocator->state;

  for (; iter < end; iter++) {
    code_root* root = *iter;
    cell block = root->value & (~data_alignment - 1);
    if (root->valid && !state->marked_p(block))
      root->valid = false;
  }
}

void factor_vm::collect_mark_impl() {
  gc_workhorse<tenured_space, full_policy>
      workhorse(this, this->data->tenured, full_policy(this));

  slot_visitor<gc_workhorse<tenured_space, full_policy> >
                visitor(this, workhorse);

  mark_stack.clear();

  code->allocator->state.clear_mark_bits();
  data->tenured->state.clear_mark_bits();

  visitor.visit_all_roots();
  visitor.visit_context_code_blocks();
  visitor.visit_uninitialized_code_blocks();

  while (!mark_stack.empty()) {
    cell ptr = mark_stack.back();
    mark_stack.pop_back();

    if (ptr & 1) {
      code_block* compiled = (code_block*)(ptr - 1);
      visitor.visit_code_block_objects(compiled);
      visitor.visit_embedded_literals(compiled);
      visitor.visit_embedded_code_pointers(compiled);
    } else {
      object* obj = (object*)ptr;
      visitor.visit_slots(obj);
      if (obj->type() == ALIEN_TYPE)
        ((alien*)obj)->update_address();
      visitor.visit_object_code_block(obj);
    }
  }
  data->reset_tenured();
  data->reset_aging();
  data->reset_nursery();
  code->clear_remembered_set();
}

void factor_vm::collect_sweep_impl() {
  gc_event* event = current_gc->event;

  if (event)
    event->started_data_sweep();
  data->tenured->sweep();
  if (event)
    event->ended_data_sweep();

  update_code_roots_for_sweep();

  if (event)
    event->started_code_sweep();
  code->sweep();
  if (event)
    event->ended_code_sweep();
}

void factor_vm::collect_full() {
  collect_mark_impl();
  collect_sweep_impl();

  if (data->low_memory_p()) {
    /* Full GC did not free up enough memory. Grow the heap. */
    set_current_gc_op(collect_growing_heap_op);
    collect_growing_heap(0);
  } else if (data->high_fragmentation_p()) {
    /* Enough free memory, but it is not contiguous. Perform a
       compaction. */
    set_current_gc_op(collect_compact_op);
    collect_compact_impl();
  }

  code->flush_icache();
}

}
