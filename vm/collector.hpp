namespace factor
{

template<typename TargetGeneration, typename Policy> struct collector_workhorse {
	factor_vm *parent;
	generation_statistics *stats;
	TargetGeneration *target;
	Policy policy;

	explicit collector_workhorse(factor_vm *parent_, generation_statistics *stats_, TargetGeneration *target_, Policy policy_) :
		parent(parent_),
		stats(stats_),
		target(target_),
		policy(policy_) {}

	object *resolve_forwarding(object *untagged)
	{
		parent->check_data_pointer(untagged);

		/* is there another forwarding pointer? */
		while(untagged->h.forwarding_pointer_p())
			untagged = untagged->h.forwarding_pointer();

		/* we've found the destination */
		untagged->h.check_header();
		return untagged;
	}

	object *promote_object(object *untagged)
	{
		cell size = untagged->size();
		object *newpointer = target->allot(size);
		/* XXX not exception-safe */
		if(!newpointer) longjmp(parent->current_gc->gc_unwind,1);

		memcpy(newpointer,untagged,size);
		untagged->h.forward_to(newpointer);

		stats->object_count++;
		stats->bytes_copied += size;

		policy.promoted_object(newpointer);

		return newpointer;
	}

	object *visit_handle(object *obj)
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
inline static slot_visitor<collector_workhorse<TargetGeneration,Policy> > make_collector_workhorse(
	factor_vm *parent,
	generation_statistics *stats,
	TargetGeneration *target,
	Policy policy)
{
	return slot_visitor<collector_workhorse<TargetGeneration,Policy> >(parent,
		collector_workhorse<TargetGeneration,Policy>(parent,stats,target,policy));
}

template<typename TargetGeneration, typename Policy> struct collector {
	factor_vm *parent;
	data_heap *data;
	code_heap *code;
	generation_statistics *stats;
	TargetGeneration *target;
	slot_visitor<collector_workhorse<TargetGeneration,Policy> > workhorse;

	explicit collector(factor_vm *parent_, generation_statistics *stats_, TargetGeneration *target_, Policy policy_) :
		parent(parent_),
		data(parent_->data),
		code(parent_->code),
		stats(stats_),
		target(target_),
		workhorse(make_collector_workhorse(parent_,stats_,target_,policy_)) {}

	void trace_handle(cell *handle)
	{
		workhorse.visit_handle(handle);
	}

	void trace_slots(object *ptr)
	{
		workhorse.visit_slots(ptr);
	}

	void trace_roots()
	{
		workhorse.visit_roots();
	}

	void trace_contexts()
	{
		workhorse.visit_contexts();
	}

	/* Trace all literals referenced from a code block. Only for aging and nursery collections */
	void trace_literal_references(code_block *compiled)
	{
		workhorse.visit_literal_references(compiled);
	}

	void trace_code_heap_roots(std::set<code_block *> *remembered_set)
	{
		std::set<code_block *>::const_iterator iter = remembered_set->begin();
		std::set<code_block *>::const_iterator end = remembered_set->end();

		for(; iter != end; iter++)
		{
			trace_literal_references(*iter);
			parent->gc_stats.code_blocks_scanned++;
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

			if(slot_ptr != end_ptr)
			{
				for(; slot_ptr < end_ptr; slot_ptr++)
					workhorse.visit_handle(slot_ptr);
			}
		}
	}

	template<typename SourceGeneration, typename Unmarker>
	void trace_cards(SourceGeneration *gen, card mask, Unmarker unmarker)
	{
		u64 start_time = current_micros();
	
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
				parent->gc_stats.decks_scanned++;

				cell first_card = first_card_in_deck(deck_index);
				cell last_card = last_card_in_deck(deck_index);
	
				for(cell card_index = first_card; card_index < last_card; card_index++)
				{
					if(cards[card_index] & mask)
					{
						parent->gc_stats.cards_scanned++;

						if(end < card_start_address(card_index))
						{
							start = gen->starts.find_object_containing_card(card_index - gen_start_card);
							binary_start = start + parent->binary_payload_start((object *)start);
							end = start + ((object *)start)->size();
						}
	
#ifdef FACTOR_DEBUG
						assert(addr_to_card(start - data->start) <= card_index);
						assert(start < card_end_address(card_index));
#endif

scan_next_object:				{
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
									binary_start = start + parent->binary_payload_start((object *)start);
									end = start + ((object *)start)->size();
									goto scan_next_object;
								}
							}
						}
	
						unmarker(&cards[card_index]);
	
						if(!start) goto end;
					}
				}
	
				unmarker(&decks[deck_index]);
			}
		}

end:		parent->gc_stats.card_scan_time += (current_micros() - start_time);
	}
};

}
