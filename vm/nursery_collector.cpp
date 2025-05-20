#include "master.hpp"

namespace factor {

struct nursery_copier : no_fixup {
  bump_allocator* nursery;
  aging_space* aging;

  nursery_copier(bump_allocator* nursery, aging_space* aging)
      : nursery(nursery), aging(aging) { }

  object* fixup_data(object* obj) {
    if (!nursery->contains_p(obj)) {
      return obj;
    }

    // The while-loop is a needed micro-optimization.
    while (obj->forwarding_pointer_p()) {
      obj = obj->forwarding_pointer();
    }

    if (!nursery->contains_p(obj)) {
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

void factor_vm::collect_nursery() {
  // Check that necessary data structures exist
  if (!data || !data->nursery || !data->aging || !data->tenured || !code) {
    critical_error("in collect_nursery, NULL data structure", 0);
    return;
  }

  // Copy live objects from the nursery (as determined by the root set and
  // marked cards in aging and tenured) to aging space.
  slot_visitor<nursery_copier>
      visitor(this, nursery_copier(data->nursery, data->aging));

  cell scan = data->aging->start + data->aging->occupied_space();

  visitor.visit_all_roots();
  
  // Safe access to event through current_gc
  gc_event* event = current_gc ? current_gc->event : NULL;

  if (event)
    event->reset_timer();
    
  visitor.visit_cards(data->tenured, card_points_to_nursery,
                      card_points_to_nursery);
  visitor.visit_cards(data->aging, card_points_to_nursery, 0xff);
  
  if (event) {
    event->ended_phase(PHASE_CARD_SCAN);
    event->cards_scanned += visitor.cards_scanned;
    event->decks_scanned += visitor.decks_scanned;
  }

  if (event)
    event->reset_timer();
    
  // Make sure code is not NULL before accessing points_to_nursery
  if (code) {
    visitor.visit_code_heap_roots(&code->points_to_nursery);
    
    if (event) {
      event->ended_phase(PHASE_CODE_SCAN);
      event->code_blocks_scanned += code->points_to_nursery.size();
    }
  }

  visitor.cheneys_algorithm(data->aging, scan);

  data->reset_nursery();
  
  // Check code again before clearing
  if (code) {
    code->points_to_nursery.clear();
  }
}

}
