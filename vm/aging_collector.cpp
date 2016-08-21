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
  // Promote objects referenced from tenured space to tenured space, copy
  // everything else to the aging semi-space, and reset the nursery pointer.
  {
    // Change the op so that if we fail here, an assertion will be raised.
    current_gc->op = collect_to_tenured_op;

    gc_workhorse<tenured_space, to_tenured_policy>
        workhorse(this, data->tenured, to_tenured_policy(this));
    slot_visitor<gc_workhorse<tenured_space, to_tenured_policy>>
        visitor(this, workhorse);

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
  }
  {
    // If collection fails here, do a to_tenured collection.
    current_gc->op = collect_aging_op;

    std::swap(data->aging, data->aging_semispace);
    data->reset_aging();

    aging_space *target = data->aging;
    gc_workhorse<aging_space, aging_policy>
        workhorse(this, target, aging_policy(this));
    slot_visitor<gc_workhorse<aging_space, aging_policy>>
        visitor(this, workhorse);
    cell scan = target->start + target->occupied_space();

    visitor.visit_all_roots();
    visitor.cheneys_algorithm(target, scan);

    data->reset_nursery();
    code->clear_remembered_set();
  }
}

}
