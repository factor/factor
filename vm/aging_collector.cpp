#include "master.hpp"

namespace factor {

// On x86-64, we want 16-byte alignment for SSE/AVX operations
// On x86-32, we don't need this strict alignment
#ifdef FACTOR_64
struct alignas(16) to_aging_copier : no_fixup {
#else
struct to_aging_copier : no_fixup {
#endif
  aging_space* aging;
  tenured_space* tenured;

  to_aging_copier() : aging(nullptr), tenured(nullptr) { }
  
  to_aging_copier(aging_space* aging_, tenured_space* tenured_)
      : aging(aging_), tenured(tenured_) { }
  
  to_aging_copier(const to_aging_copier& other)
      : aging(other.aging), tenured(other.tenured) { }
  
  to_aging_copier& operator=(const to_aging_copier& other) {
    if (this != &other) {
      aging = other.aging;
      tenured = other.tenured;
    }
    return *this;
  }

  object* fixup_data(object* obj) {
    if (aging->contains_p(obj) || tenured->contains_p(obj)) {
      return obj;
    }

    // Is there another forwarding pointer?
    while (obj->forwarding_pointer_p()) {
      object* dest = obj->forwarding_pointer();
      obj = dest;
    }

    if (aging->contains_p(obj) || tenured->contains_p(obj)) {
      return obj;
    }

    cell size = obj->size();
    object* newpointer = aging->allot(size);
    if (!newpointer)
      throw must_start_gc_again();

    memcpy(newpointer, obj, size);
    obj->forward_to(newpointer);

    return newpointer;
  }
};

void factor_vm::collect_aging() {
  // Promote objects referenced from tenured space to tenured space, copy
  // everything else to the aging semi-space, and reset the nursery pointer.
  {
    // Change the op so that if we fail here, an assertion will be raised.
    current_gc->op = COLLECT_TO_TENURED_OP;

    from_tenured_refs_copier copier(data->tenured.get(), &mark_stack);
    slot_visitor<from_tenured_refs_copier> visitor(this, copier);

    gc_event* event = current_gc->event.get();

    if (event)
      event->reset_timer();
    visitor.visit_cards(data->tenured.get(), card_points_to_aging, 0xff);
    if (event) {
      event->ended_phase(PHASE_CARD_SCAN);
      event->cards_scanned += visitor.cards_scanned;
      event->decks_scanned += visitor.decks_scanned;
    }

    if (event)
      event->reset_timer();
    visitor.visit_code_heap_roots(&code->points_to_aging);
    if (event) {
      event->ended_phase(PHASE_CODE_SCAN);
      event->code_blocks_scanned += code->points_to_aging.size();
    }
    visitor.visit_mark_stack(&mark_stack);
  }
  {
    // If collection fails here, do a to_tenured collection.
    current_gc->op = COLLECT_AGING_OP;

    std::swap(data->aging, data->aging_semispace);
    data->reset_aging();

    aging_space *aging = data->aging.get();
    to_aging_copier copier(aging, data->tenured.get());
    slot_visitor<to_aging_copier> visitor(this, copier);

    cell scan = aging->start + aging->occupied_space();

    visitor.visit_all_roots();
    visitor.cheneys_algorithm(aging, scan);

    data->reset_nursery();
    code->clear_remembered_set();
  }
}

}
