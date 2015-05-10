#include "master.hpp"

namespace factor {

struct aging_policy {
  aging_space* aging;
  tenured_space* tenured;

  explicit aging_policy(factor_vm* parent)
      : aging(parent->data->aging), tenured(parent->data->tenured) {}

  bool should_copy_p(object* untagged) {
    return !(aging->contains_p(untagged) || tenured->contains_p(untagged));
  }

  void promoted_object(object* obj) {}

  void visited_object(object* obj) {}
};

void factor_vm::collect_aging() {
  /* Promote objects referenced from tenured space to tenured space, copy
     everything else to the aging semi-space, and reset the nursery pointer. */
  {
    /* Change the op so that if we fail here, an assertion will be
       raised. */
    current_gc->op = collect_to_tenured_op;

    collector<tenured_space, to_tenured_policy> collector(this,
                                                          this->data->tenured,
                                                          to_tenured_policy(this));
    gc_event* event = current_gc->event;

    if (event)
      event->started_card_scan();
    collector.trace_cards(data->tenured, card_points_to_aging, 0xff);
    if (event)
      event->ended_card_scan(collector.cards_scanned, collector.decks_scanned);

    if (event)
      event->started_code_scan();
    collector.trace_code_heap_roots(&code->points_to_aging);
    if (event)
      event->ended_code_scan(collector.code_blocks_scanned);

    collector.visitor.visit_mark_stack(&mark_stack);
  }
  {
    /* If collection fails here, do a to_tenured collection. */
    current_gc->op = collect_aging_op;

    std::swap(data->aging, data->aging_semispace);
    data->reset_aging();

    collector<aging_space, aging_policy> collector(this,
                                                   this->data->aging,
                                                   aging_policy(this));

    collector.visitor.visit_all_roots();
    collector.cheneys_algorithm();

    data->reset_nursery();
    code->clear_remembered_set();
  }
}

}
