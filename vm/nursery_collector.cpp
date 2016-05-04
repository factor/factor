#include "master.hpp"

namespace factor {

struct nursery_policy {
  bump_allocator* nursery;

  explicit nursery_policy(bump_allocator* nursery) : nursery(nursery) {}

  bool should_copy_p(object* obj) {
    return nursery->contains_p(obj);
  }

  void promoted_object(object* obj) {}

  void visited_object(object* obj) {}
};

void factor_vm::collect_nursery() {

  /* Copy live objects from the nursery (as determined by the root set and
     marked cards in aging and tenured) to aging space. */
  gc_workhorse<aging_space, nursery_policy>
      workhorse(this, data->aging, nursery_policy(data->nursery));
  slot_visitor<gc_workhorse<aging_space, nursery_policy>>
      visitor(this, workhorse);

  cell scan = data->aging->start + data->aging->occupied_space();

  visitor.visit_all_roots();
  gc_event* event = current_gc->event;

  if (event)
    event->reset_timer();
  visitor.visit_cards(data->tenured, card_points_to_nursery,
                      card_points_to_nursery);
  visitor.visit_cards(data->aging, card_points_to_nursery, 0xff);
  if (event)
    event->ended_card_scan(visitor.cards_scanned, visitor.decks_scanned);

  if (event)
    event->reset_timer();
  visitor.visit_code_heap_roots(&code->points_to_nursery);
  if (event)
    event->ended_code_scan(code->points_to_nursery.size());

  visitor.cheneys_algorithm(data->aging, scan);

  data->reset_nursery();
  code->points_to_nursery.clear();
}

}
