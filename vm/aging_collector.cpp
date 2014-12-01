#include "master.hpp"

namespace factor {

void factor_vm::collect_aging() {
  /* Promote objects referenced from tenured space to tenured space, copy
     everything else to the aging semi-space, and reset the nursery pointer. */
  {
    /* Change the op so that if we fail here, an assertion will be
       raised. */
    current_gc->op = collect_to_tenured_op;

    to_tenured_collector collector(this);

    gc_event* event = current_gc->event;

    if (event)
      event->started_card_scan();
    collector.trace_cards(data->tenured, card_points_to_aging, full_unmarker());
    if (event)
      event->ended_card_scan(collector.cards_scanned, collector.decks_scanned);

    if (event)
      event->started_code_scan();
    collector.trace_code_heap_roots(&code->points_to_aging);
    if (event)
      event->ended_code_scan(collector.code_blocks_scanned);

    collector.tenure_reachable_objects();
  }
  {
    /* If collection fails here, do a to_tenured collection. */
    current_gc->op = collect_aging_op;

    std::swap(data->aging, data->aging_semispace);
    data->reset_generation(data->aging);

    copying_collector<aging_space, aging_policy> collector(this,
                                                           this->data->aging,
                                                           aging_policy(this));
    collector.trace_roots();
    collector.trace_contexts();

    collector.cheneys_algorithm();

    data->reset_generation(&nursery);
    code->clear_remembered_set();
  }
}

}
