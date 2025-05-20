#include "master.hpp"

namespace factor {

struct to_aging_copier : no_fixup {
  aging_space* aging;
  tenured_space* tenured;

  to_aging_copier(aging_space* aging, tenured_space* tenured)
      : aging(aging), tenured(tenured) { }

  object* fixup_data(object* obj) {
    if (aging->contains_p(obj) || tenured->contains_p(obj)) {
      return obj;
    }

    // Is there another forwarding pointer?
    // Adding cycle detection to prevent infinite loops in forwarding pointers
    const unsigned int MAX_FORWARDING_CHAIN = 100;
    unsigned int count = 0;
    
    while (obj->forwarding_pointer_p() && count < MAX_FORWARDING_CHAIN) {
      object* dest = obj->forwarding_pointer();
      obj = dest;
      count++;
    }
    
    // If we hit the limit, there might be a cycle
    if (count >= MAX_FORWARDING_CHAIN) {
      // Break the potential cycle by returning the last object we found
      // This may be wrong, but it's better than an infinite loop
      factor::critical_error("Possible forwarding pointer cycle detected in aging_collector", (cell)obj);
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
  // Check that necessary data structures exist
  if (!data || !data->nursery || !data->aging || !data->aging_semispace || 
      !data->tenured || !code || !current_gc) {
    critical_error("in collect_aging, NULL data structure", 0);
    return;
  }

  // Promote objects referenced from tenured space to tenured space, copy
  // everything else to the aging semi-space, and reset the nursery pointer.
  {
    // Change the op so that if we fail here, an assertion will be raised.
    current_gc->op = COLLECT_TO_TENURED_OP;

    slot_visitor<from_tenured_refs_copier>
        visitor(this, from_tenured_refs_copier(data->tenured, &mark_stack));

    // Safe access to event through current_gc
    gc_event* event = current_gc ? current_gc->event : NULL;

    if (event)
      event->reset_timer();
      
    visitor.visit_cards(data->tenured, card_points_to_aging, 0xff);
    
    if (event) {
      event->ended_phase(PHASE_CARD_SCAN);
      event->cards_scanned += visitor.cards_scanned;
      event->decks_scanned += visitor.decks_scanned;
    }

    if (event)
      event->reset_timer();
      
    // Make sure code exists before accessing
    if (code) {
      visitor.visit_code_heap_roots(&code->points_to_aging);
      
      if (event) {
        event->ended_phase(PHASE_CODE_SCAN);
        event->code_blocks_scanned += code->points_to_aging.size();
      }
    }
    
    visitor.visit_mark_stack(&mark_stack);
  }
  
  {
    // If collection fails here, do a to_tenured collection.
    if (current_gc) {  // Safety check
      current_gc->op = COLLECT_AGING_OP;
    }

    std::swap(data->aging, data->aging_semispace);
    data->reset_aging();

    aging_space *aging = data->aging;
    if (!aging) {  // Safety check
      critical_error("in collect_aging, aging space is NULL", 0);
      return;
    }
    
    slot_visitor<to_aging_copier>
        visitor(this, to_aging_copier(aging, data->tenured));

    cell scan = aging->start + aging->occupied_space();

    visitor.visit_all_roots();
    visitor.cheneys_algorithm(aging, scan);

    data->reset_nursery();
    
    // Check code exists before clearing
    if (code) {
      code->clear_remembered_set();
    }
  }
}

}
