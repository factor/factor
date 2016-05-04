#include "master.hpp"

namespace factor {

void factor_vm::collect_to_tenured() {
  /* Copy live objects from aging space to tenured space. */
  gc_workhorse<tenured_space, to_tenured_policy>
      workhorse(this, data->tenured, to_tenured_policy(this));
  slot_visitor<gc_workhorse<tenured_space, to_tenured_policy>>
      visitor(this, workhorse);

  mark_stack.clear();

  visitor.visit_all_roots();
  gc_event* event = current_gc->event;

  if (event)
    event->reset_timer();
  visitor.visit_cards(data->tenured, card_points_to_aging, 0xff);
  if (event)
    event->ended_card_scan(visitor.cards_scanned, visitor.decks_scanned);

  if (event)
    event->reset_timer();
  visitor.visit_code_heap_roots(&code->points_to_aging);
  if (event)
    event->ended_code_scan(code->points_to_aging.size());

  visitor.visit_mark_stack(&mark_stack);

  data->reset_nursery();
  data->reset_aging();
  code->clear_remembered_set();
}

}
