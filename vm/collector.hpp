namespace factor {

struct must_start_gc_again {
};

template <typename TargetGeneration, typename Policy>
struct gc_workhorse : no_fixup {
  static const bool translated_code_block_map = false;

  factor_vm* parent;
  TargetGeneration* target;
  Policy policy;
  code_heap* code;

  gc_workhorse(factor_vm* parent, TargetGeneration* target, Policy policy)
      : parent(parent), target(target), policy(policy), code(parent->code) {}

  object* fixup_data(object* obj) {
    FACTOR_ASSERT((parent->current_gc &&
                   parent->current_gc->op == collect_growing_heap_op) ||
                  parent->data->seg->in_segment_p((cell)obj));

    if (!policy.should_copy_p(obj)) {
      policy.visited_object(obj);
      return obj;
    }

    /* is there another forwarding pointer? */
    while (obj->forwarding_pointer_p()) {
      object* dest = obj->forwarding_pointer();
      obj = dest;
    }

    if (!policy.should_copy_p(obj)) {
      policy.visited_object(obj);
      return obj;
    }

    cell size = obj->size();
    object* newpointer = target->allot(size);
    if (!newpointer)
      throw must_start_gc_again();

    memcpy(newpointer, obj, size);
    obj->forward_to(newpointer);

    policy.promoted_object(newpointer);

    return newpointer;
  }

  code_block* fixup_code(code_block* compiled) {
    if (!code->allocator->state.marked_p((cell)compiled)) {
      code->allocator->state.set_marked_p((cell)compiled, compiled->size());
      parent->mark_stack.push_back((cell)compiled + 1);
    }

    return compiled;
  }
};

template <typename TargetGeneration, typename Policy> struct collector {
  factor_vm* parent;
  data_heap* data;
  code_heap* code;
  TargetGeneration* target;
  gc_workhorse<TargetGeneration, Policy> workhorse;
  slot_visitor<gc_workhorse<TargetGeneration, Policy> > visitor;
  cell cards_scanned;
  cell decks_scanned;
  cell code_blocks_scanned;

  collector(factor_vm* parent, TargetGeneration* target, Policy policy)
      : parent(parent),
        data(parent->data),
        code(parent->code),
        target(target),
        workhorse(parent, target, policy),
        visitor(parent, workhorse),
        cards_scanned(0),
        decks_scanned(0),
        code_blocks_scanned(0) {}

  void trace_code_heap_roots(std::set<code_block*>* remembered_set) {
    std::set<code_block*>::const_iterator iter = remembered_set->begin();
    std::set<code_block*>::const_iterator end = remembered_set->end();

    for (; iter != end; iter++) {
      code_block* compiled = *iter;
      visitor.visit_code_block_objects(compiled);
      visitor.visit_embedded_literals(compiled);
      compiled->flush_icache();
      code_blocks_scanned++;
    }
  }

  void trace_partial_objects(cell start, cell card_start, cell card_end) {
    object* obj = (object*)start;
    cell end = start + obj->binary_payload_start();
    if (card_start < end) {
      start += sizeof(cell);

      start = std::max(start, card_start);
      end = std::min(end, card_end);

      cell* slot_ptr = (cell*)start;
      cell* end_ptr = (cell*)end;

      for (; slot_ptr < end_ptr; slot_ptr++)
        visitor.visit_handle(slot_ptr);
    }
  }

  template <typename SourceGeneration>
  cell trace_card(SourceGeneration* gen, cell index, cell start) {

    cell start_addr = data->start + index * card_size;
    cell end_addr = start_addr + card_size;

    if (!start || (start + ((object*)start)->size()) < start_addr) {
      /* Optimization because finding the objects in a memory range is
         expensive. It helps a lot when tracing consecutive cards. */
      cell gen_start_card = (gen->start - data->start) / card_size;
      start = gen->starts
          .find_object_containing_card(index - gen_start_card);
    }

    while (start && start < end_addr) {
      trace_partial_objects(start, start_addr, end_addr);
      if ((start + ((object*)start)->size()) >= end_addr) {
        /* The object can overlap the card boundary, then the
           remainder of it will be handled in the next card
           tracing if that card is marked. */
        break;
      }
      start = gen->next_object_after(start);
    }
    return start;
  }

  template <typename SourceGeneration>
  void trace_cards(SourceGeneration* gen, card mask, card unmask) {
    card_deck* decks = data->decks;
    card_deck* cards = data->cards;

    cell first_deck = (gen->start - data->start) / deck_size;
    cell last_deck = (gen->end - data->start) / deck_size;

    /* Address of last traced object. */
    cell start = 0;

    for (cell deck_index = first_deck; deck_index < last_deck; deck_index++) {
      if (decks[deck_index] & mask) {
        decks[deck_index] &= ~unmask;
        decks_scanned++;

        cell first_card = cards_per_deck * deck_index;
        cell last_card = first_card + cards_per_deck;

        for (cell card_index = first_card; card_index < last_card;
             card_index++) {
          if (cards[card_index] & mask) {
            cards[card_index] &= ~unmask;
            cards_scanned++;

            start = trace_card(gen, card_index, start);
            if (!start) {
              /* At end of generation, no need to scan more cards. */
              return;
            }
          }
        }
      }
    }
  }
};

}
