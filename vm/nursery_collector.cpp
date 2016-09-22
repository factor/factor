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

    if (obj->forwarding_pointer_p()) {
      object* dest = obj->forwarding_pointer();
      FACTOR_ASSERT(!nursery->contains_p(dest));
      return dest;
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
  // Copy live objects from the nursery (as determined by the root set and
  // marked cards in aging and tenured) to aging space.
  slot_visitor<nursery_copier>
      visitor(this, nursery_copier(data->nursery, data->aging));

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
