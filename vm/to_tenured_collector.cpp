#include "master.hpp"

namespace factor {

void factor_vm::collect_to_tenured() {
  // Copy live objects from aging space to tenured space.
  mark_stack.clear();
  slot_visitor<from_tenured_refs_copier>
      visitor(this, from_tenured_refs_copier(data->tenured.get(), &mark_stack));

  visitor.visit_all_roots();
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

  data->reset_nursery();
  data->reset_aging();
  code->clear_remembered_set();
}

}
