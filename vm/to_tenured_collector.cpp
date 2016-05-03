#include "master.hpp"

namespace factor {

void factor_vm::collect_to_tenured() {
  /* Copy live objects from aging space to tenured space. */
  collector<tenured_space, to_tenured_policy> collector(this,
                                                        data->tenured,
                                                        to_tenured_policy(this));

  mark_stack.clear();

  collector.visitor.visit_all_roots();
  gc_event* event = current_gc->event;

  if (event)
    event->reset_timer();
  collector.visitor.visit_cards(data->tenured, card_points_to_aging, 0xff);
  if (event) {
    event->ended_card_scan(collector.visitor.cards_scanned,
                           collector.visitor.decks_scanned);
  }

  if (event)
    event->reset_timer();
  collector.visitor.visit_code_heap_roots(&code->points_to_aging);
  if (event)
    event->ended_code_scan(code->points_to_aging.size());

  collector.visitor.visit_mark_stack(&mark_stack);

  data->reset_nursery();
  data->reset_aging();
  code->clear_remembered_set();
}

}
