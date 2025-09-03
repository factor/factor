#include "master.hpp"

namespace factor {

gc_event::gc_event(gc_op op, factor_vm* parent)
    : op(op),
      cards_scanned(0),
      decks_scanned(0),
      code_blocks_scanned(0),
      start_time(nano_count()),
      times{0} {
  data_heap_before = parent->data_room();
  code_heap_before = parent->code->allocator->as_allocator_room();
  start_time = nano_count();
}

void gc_event::reset_timer() { temp_time = nano_count(); }

void gc_event::ended_phase(gc_phase phase) {
  times[phase] = static_cast<cell>(nano_count() - temp_time);
}

void gc_event::ended_gc(factor_vm* parent) {
  data_heap_after = parent->data_room();
  code_heap_after = parent->code->allocator->as_allocator_room();
  total_time = static_cast<cell>(nano_count() - start_time);
}

gc_state::gc_state(gc_op op, factor_vm* parent) : op(op) {
  if (parent->gc_events) {
    event = std::make_unique<gc_event>(op, parent);
    start_time = nano_count();
  }
  // unique_ptr automatically initializes to nullptr
}

gc_state::~gc_state() {
  // unique_ptr automatically handles deletion
}

void factor_vm::start_gc_again() {
  if (current_gc->op == COLLECT_NURSERY_OP) {
    // Nursery collection can fail if aging does not have enough
    // free space to fit all live objects from nursery.
    current_gc->op = COLLECT_AGING_OP;
  } else if (current_gc->op == COLLECT_AGING_OP) {
    // Aging collection can fail if the aging semispace cannot fit
    // all the live objects from the other aging semispace and the
    // nursery.
    current_gc->op = COLLECT_TO_TENURED_OP;
  } else {
    // Nothing else should fail mid-collection due to insufficient
    // space in the target generation.
    critical_error("in start_gc_again, bad GC op", current_gc->op);
  }
}

void factor_vm::set_current_gc_op(gc_op op) {
  current_gc->op = op;
  if (gc_events)
    current_gc->event->op = op;
}

void factor_vm::gc(gc_op op, cell requested_size) {
  FACTOR_ASSERT(!gc_off);
  FACTOR_ASSERT(!current_gc);

  // Important invariant: tenured space must have enough contiguous free
  // space to fit the entire contents of the aging space and nursery. This is
  // because when doing a full collection, objects from younger generations
  // are promoted before any unreachable tenured objects are freed.
  FACTOR_ASSERT(!data->high_fragmentation_p());

  current_gc = std::make_unique<gc_state>(op, this);
  if (ctx)
    ctx->callstack_seg->set_border_locked(false);
  atomic::store(&current_gc_p, true);

  // Keep trying to GC higher and higher generations until we don't run
  // out of space in the target generation.
  for (;;) {
    try {
      if (gc_events)
        current_gc->event->op = current_gc->op;

      switch (current_gc->op) {
        case COLLECT_NURSERY_OP:
          collect_nursery();
          break;
        case COLLECT_AGING_OP:
          // We end up here if the above fails.
          collect_aging();
          if (data->high_fragmentation_p()) {
            // Change GC op so that if we fail again, we crash.
            set_current_gc_op(COLLECT_FULL_OP);
            collect_full();
          }
          break;
        case COLLECT_TO_TENURED_OP:
          // We end up here if the above fails.
          collect_to_tenured();
          if (data->high_fragmentation_p()) {
            // Change GC op so that if we fail again, we crash.
            set_current_gc_op(COLLECT_FULL_OP);
            collect_full();
          }
          break;
        case COLLECT_FULL_OP:
          collect_full();
          break;
        case COLLECT_COMPACT_OP:
          collect_compact();
          break;
        case COLLECT_GROWING_DATA_HEAP_OP:
          collect_growing_data_heap(requested_size);
          break;
        default:
          critical_error("in gc, bad GC op", current_gc->op);
          break;
      }

      break;
    }
    catch (const must_start_gc_again&) {
      // We come back here if the target generation is full.
      start_gc_again();
    }
  }

  if (gc_events) {
    current_gc->event->ended_gc(this);
    gc_events->push_back(*current_gc->event);
  }

  atomic::store(&current_gc_p, false);
  if (ctx)
    ctx->callstack_seg->set_border_locked(true);
  current_gc.reset();

  // Check the invariant again, just in case.
  FACTOR_ASSERT(!data->high_fragmentation_p());
}

void factor_vm::primitive_minor_gc() {
  gc(COLLECT_NURSERY_OP, 0);
}

void factor_vm::primitive_full_gc() {
  gc(COLLECT_FULL_OP, 0);
}

void factor_vm::primitive_compact_gc() {
  gc(COLLECT_COMPACT_OP, 0);
}

void factor_vm::primitive_enable_gc_events() {
  gc_events = std::make_unique<std::vector<gc_event>>();
}

// Allocates memory (byte_array_from_value, result.add)
// XXX: Remember that growable_array has a data_root already
void factor_vm::primitive_disable_gc_events() {
  if (gc_events) {
    growable_array result(this);

    auto saved_gc_events = std::move(this->gc_events);
    this->gc_events.reset();

    for (const auto& event : *saved_gc_events) {
      byte_array* obj = byte_array_from_value(&event);
      result.add(tag<byte_array>(obj));
    }

    result.trim();
    ctx->push(result.elements.value());

    // unique_ptr automatically handles deletion
  } else
    ctx->push(false_object);
}

}
