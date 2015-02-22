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

    object* untagged = obj;
    /* is there another forwarding pointer? */
    while (untagged->forwarding_pointer_p())
      untagged = untagged->forwarding_pointer();

    if (!policy.should_copy_p(untagged)) {
      policy.visited_object(untagged);
      return untagged;
    }

    cell size = untagged->size();
    object* newpointer = target->allot(size);
    if (!newpointer)
      throw must_start_gc_again();

    memcpy(newpointer, untagged, size);
    untagged->forward_to(newpointer);

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

  void trace_object(object* ptr) {
    visitor.visit_slots(ptr);
    if (ptr->type() == ALIEN_TYPE)
      ((alien*)ptr)->update_address();
  }

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

  cell first_card_in_deck(cell deck) {
    return deck << (deck_bits - card_bits);
  }

  cell last_card_in_deck(cell deck) {
    return first_card_in_deck(deck + 1);
  }

  cell card_deck_for_address(cell a) {
    return addr_to_deck(a - data->start);
  }

  cell card_start_address(cell card) {
    return (card << card_bits) + data->start;
  }

  cell card_end_address(cell card) {
    return ((card + 1) << card_bits) + data->start;
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
  void trace_cards(SourceGeneration* gen, card mask, card unmask) {
    card_deck* decks = data->decks;
    card_deck* cards = data->cards;

    cell gen_start_card = addr_to_card(gen->start - data->start);

    cell first_deck = card_deck_for_address(gen->start);
    cell last_deck = card_deck_for_address(gen->end);

    cell start = 0;
    cell end = 0;

    for (cell deck_index = first_deck; deck_index < last_deck; deck_index++) {
      if (decks[deck_index] & mask) {
        decks_scanned++;

        cell first_card = first_card_in_deck(deck_index);
        cell last_card = last_card_in_deck(deck_index);

        for (cell card_index = first_card; card_index < last_card;
             card_index++) {
          if (cards[card_index] & mask) {
            cards_scanned++;

            cell start_addr = card_start_address(card_index);
            cell end_addr = card_end_address(card_index);

            if (end < start_addr) {
              factor_print_p = true;
              start = gen->starts
                  .find_object_containing_card(card_index - gen_start_card);

              end = start + ((object*)start)->size();
            }

          scan_next_object:
            if (start < end_addr) {
              trace_partial_objects(start, start_addr, end_addr);
              if (end < end_addr) {
                start = gen->next_object_after(start);
                if (start) {
                  end = start + ((object*)start)->size();
                  goto scan_next_object;
                }
              }
            }
            if (!start) {
              return;
            }
          }
          cards[card_index] &= ~unmask;
        }

        decks[deck_index] &= ~unmask;
      }
    }
  }
};

}
