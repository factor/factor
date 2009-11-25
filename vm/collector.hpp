namespace factor
{

template<typename TargetGeneration, typename Policy> struct data_workhorse {
	factor_vm *parent;
	TargetGeneration *target;
	Policy policy;

	explicit data_workhorse(factor_vm *parent_, TargetGeneration *target_, Policy policy_) :
		parent(parent_),
		target(target_),
		policy(policy_) {}

	object *resolve_forwarding(object *untagged)
	{
		parent->check_data_pointer(untagged);

		/* is there another forwarding pointer? */
		while(untagged->forwarding_pointer_p())
			untagged = untagged->forwarding_pointer();

		/* we've found the destination */
		return untagged;
	}

	object *promote_object(object *untagged)
	{
		cell size = untagged->size();
		object *newpointer = target->allot(size);
		/* XXX not exception-safe */
		if(!newpointer) longjmp(parent->current_gc->gc_unwind,1);

		memcpy(newpointer,untagged,size);
		untagged->forward_to(newpointer);

		policy.promoted_object(newpointer);

		return newpointer;
	}

	object *operator()(object *obj)
	{
		if(!policy.should_copy_p(obj))
		{
			policy.visited_object(obj);
			return obj;
		}

		object *forwarding = resolve_forwarding(obj);

		if(forwarding == obj)
			return promote_object(obj);
		else if(policy.should_copy_p(forwarding))
			return promote_object(forwarding);
		else
		{
			policy.visited_object(forwarding);
			return forwarding;
		}
	}
};

template<typename TargetGeneration, typename Policy>
inline static slot_visitor<data_workhorse<TargetGeneration,Policy> > make_data_visitor(
	factor_vm *parent,
	TargetGeneration *target,
	Policy policy)
{
	return slot_visitor<data_workhorse<TargetGeneration,Policy> >(parent,
		data_workhorse<TargetGeneration,Policy>(parent,target,policy));
}

struct dummy_unmarker {
	void operator()(card *ptr) {}
};

struct simple_unmarker {
	card unmask;
	explicit simple_unmarker(card unmask_) : unmask(unmask_) {}
	void operator()(card *ptr) { *ptr &= ~unmask; }
};

struct full_unmarker {
	explicit full_unmarker() {}
	void operator()(card *ptr) { *ptr = 0; }
};

template<typename TargetGeneration, typename Policy>
struct collector {
	factor_vm *parent;
	data_heap *data;
	code_heap *code;
	TargetGeneration *target;
	slot_visitor<data_workhorse<TargetGeneration,Policy> > data_visitor;
	cell cards_scanned;
	cell decks_scanned;
	cell code_blocks_scanned;

	explicit collector(factor_vm *parent_, TargetGeneration *target_, Policy policy_) :
		parent(parent_),
		data(parent_->data),
		code(parent_->code),
		target(target_),
		data_visitor(make_data_visitor(parent_,target_,policy_)),
		cards_scanned(0),
		decks_scanned(0),
		code_blocks_scanned(0) {}

	void trace_handle(cell *handle)
	{
		data_visitor.visit_handle(handle);
	}

	void trace_object(object *ptr)
	{
		data_visitor.visit_slots(ptr);
		if(ptr->type() == ALIEN_TYPE)
			((alien *)ptr)->update_address();
	}

	void trace_roots()
	{
		data_visitor.visit_roots();
	}

	void trace_contexts()
	{
		data_visitor.visit_contexts();
	}

	void trace_code_block_objects(code_block *compiled)
	{
		data_visitor.visit_code_block_objects(compiled);
	}

	void trace_embedded_literals(code_block *compiled)
	{
		data_visitor.visit_embedded_literals(compiled);
	}

	void trace_code_heap_roots(std::set<code_block *> *remembered_set)
	{
		std::set<code_block *>::const_iterator iter = remembered_set->begin();
		std::set<code_block *>::const_iterator end = remembered_set->end();

		for(; iter != end; iter++)
		{
			code_block *compiled = *iter;
			trace_code_block_objects(compiled);
			trace_embedded_literals(compiled);
			compiled->flush_icache();
			code_blocks_scanned++;
		}
	}

	inline cell first_card_in_deck(cell deck)
	{
		return deck << (deck_bits - card_bits);
	}

	inline cell last_card_in_deck(cell deck)
	{
		return first_card_in_deck(deck + 1);
	}

	inline cell card_deck_for_address(cell a)
	{
		return addr_to_deck(a - data->start);
	}

	inline cell card_start_address(cell card)
	{
		return (card << card_bits) + data->start;
	}

	inline cell card_end_address(cell card)
	{
		return ((card + 1) << card_bits) + data->start;
	}

	void trace_partial_objects(cell start, cell end, cell card_start, cell card_end)
	{
		if(card_start < end)
		{
			start += sizeof(cell);

			if(start < card_start) start = card_start;
			if(end > card_end) end = card_end;

			cell *slot_ptr = (cell *)start;
			cell *end_ptr = (cell *)end;

			for(; slot_ptr < end_ptr; slot_ptr++)
				data_visitor.visit_handle(slot_ptr);
		}
	}

	template<typename SourceGeneration, typename Unmarker>
	void trace_cards(SourceGeneration *gen, card mask, Unmarker unmarker)
	{
		card_deck *decks = data->decks;
		card_deck *cards = data->cards;

		cell gen_start_card = addr_to_card(gen->start - data->start);

		cell first_deck = card_deck_for_address(gen->start);
		cell last_deck = card_deck_for_address(gen->end);

		cell start = 0, binary_start = 0, end = 0;

		for(cell deck_index = first_deck; deck_index < last_deck; deck_index++)
		{
			if(decks[deck_index] & mask)
			{
				decks_scanned++;

				cell first_card = first_card_in_deck(deck_index);
				cell last_card = last_card_in_deck(deck_index);

				for(cell card_index = first_card; card_index < last_card; card_index++)
				{
					if(cards[card_index] & mask)
					{
						cards_scanned++;

						if(end < card_start_address(card_index))
						{
							start = gen->starts.find_object_containing_card(card_index - gen_start_card);
							binary_start = start + ((object *)start)->binary_payload_start();
							end = start + ((object *)start)->size();
						}

scan_next_object:				if(start < card_end_address(card_index))
						{
							trace_partial_objects(
								start,
								binary_start,
								card_start_address(card_index),
								card_end_address(card_index));
							if(end < card_end_address(card_index))
							{
								start = gen->next_object_after(start);
								if(start)
								{
									binary_start = start + ((object *)start)->binary_payload_start();
									end = start + ((object *)start)->size();
									goto scan_next_object;
								}
							}
						}

						unmarker(&cards[card_index]);

						if(!start) return;
					}
				}

				unmarker(&decks[deck_index]);
			}
		}
	}
};

}
