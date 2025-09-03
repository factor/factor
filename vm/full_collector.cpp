#include "master.hpp"

namespace factor {

struct full_collection_copier : no_fixup {
  tenured_space* tenured;
  code_heap* code;
  std::vector<cell> *mark_stack;

  full_collection_copier(tenured_space* tenured,
                         code_heap* code,
                         std::vector<cell> *mark_stack)
      : tenured(tenured), code(code), mark_stack(mark_stack) { }

  object* fixup_data(object* obj) {
    if (tenured->contains_p(obj)) {
      if (!tenured->state.marked_p(reinterpret_cast<cell>(obj))) {
        tenured->state.set_marked_p(reinterpret_cast<cell>(obj), obj->size());
        mark_stack->push_back(reinterpret_cast<cell>(obj));
      }
      return obj;
    }

    // Is there another forwarding pointer?
    while (obj->forwarding_pointer_p()) {
      object* dest = obj->forwarding_pointer();
      obj = dest;
    }

    if (tenured->contains_p(obj)) {
      if (!tenured->state.marked_p(reinterpret_cast<cell>(obj))) {
        tenured->state.set_marked_p(reinterpret_cast<cell>(obj), obj->size());
        mark_stack->push_back(reinterpret_cast<cell>(obj));
      }
      return obj;
    }

    cell size = obj->size();
    object* newpointer = tenured->allot(size);
    if (!newpointer)
      throw must_start_gc_again();
    memcpy(newpointer, obj, size);
    obj->forward_to(newpointer);

    tenured->state.set_marked_p((cell)newpointer, newpointer->size());
    mark_stack->push_back((cell)newpointer);
    return newpointer;
  }

  code_block* fixup_code(code_block* compiled) {
    if (!code->allocator->state.marked_p(reinterpret_cast<cell>(compiled))) {
      code->allocator->state.set_marked_p(reinterpret_cast<cell>(compiled), compiled->size());
      mark_stack->push_back(reinterpret_cast<cell>(compiled) + 1);
    }
    return compiled;
  }
};

void factor_vm::collect_mark_impl() {
  gc_event* event = current_gc->event.get();
  if (event)
    event->reset_timer();

  full_collection_copier copier(data->tenured.get(), code.get(), &mark_stack);
  slot_visitor<full_collection_copier> visitor(this, copier);

  mark_stack.clear();

  code->allocator->state.clear_mark_bits();
  data->tenured.get()->state.clear_mark_bits();

  visitor.visit_all_roots();
  visitor.visit_context_code_blocks();
  visitor.visit_uninitialized_code_blocks();

  visitor.visit_mark_stack(&mark_stack);

  data->reset_tenured();
  data->reset_aging();
  data->reset_nursery();
  code->clear_remembered_set();

  if (event)
    event->ended_phase(PHASE_MARKING);
}

void factor_vm::collect_sweep_impl() {
  gc_event* event = current_gc->event.get();
  if (event)
    event->reset_timer();
  data->tenured.get()->sweep();
  if (event)
    event->ended_phase(PHASE_DATA_SWEEP);

  // After a sweep, invalidate any code heap roots which are not
  // marked, so that if a block makes a tail call to a generic word,
  // and the PIC compiler triggers a GC, and the caller block gets GCd
  // as a result, the PIC code won't try to overwrite the call site
  
  // Clear code_roots list during GC to avoid accessing corrupted stack objects
  code_roots.clear();

  if (event)
    event->reset_timer();
  code->sweep();
  if (event)
    event->ended_phase(PHASE_CODE_SWEEP);
}

void factor_vm::collect_full() {
  collect_mark_impl();
  collect_sweep_impl();

  if (data->low_memory_p()) {
    // Full GC did not free up enough memory. Grow the heap.
    set_current_gc_op(COLLECT_GROWING_DATA_HEAP_OP);
    collect_growing_data_heap(0);
  } else if (data->high_fragmentation_p()) {
    // Enough free memory, but it is not contiguous. Perform a
    // compaction.
    set_current_gc_op(COLLECT_COMPACT_OP);
    collect_compact_impl();
  }

  code->flush_icache();
}

}
