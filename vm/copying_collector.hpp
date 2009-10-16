namespace factor
{

struct dummy_unmarker {
	void operator()(card *ptr) {}
};

struct simple_unmarker {
	card unmask;
	simple_unmarker(card unmask_) : unmask(unmask_) {}
	void operator()(card *ptr) { *ptr &= ~unmask; }
};

template<typename TargetGeneration, typename Policy>
struct copying_collector : collector<TargetGeneration,Policy> {
	cell scan;

	explicit copying_collector(factor_vm *myvm_, generation_statistics *stats_, TargetGeneration *target_, Policy policy_) :
		collector<TargetGeneration,Policy>(myvm_,stats_,target_,policy_), scan(target_->here) {}

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
		return addr_to_deck(a - this->data->start);
	}

	inline cell card_start_address(cell card)
	{
		return (card << card_bits) + this->data->start;
	}

	inline cell card_end_address(cell card)
	{
		return ((card + 1) << card_bits) + this->data->start;
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
					this->trace_handle(slot_ptr);
			}
		}
	}

	template<typename SourceGeneration, typename Unmarker>
	void trace_cards(SourceGeneration *gen, card mask, Unmarker unmarker)
	{
		u64 start_time = current_micros();
	
		card_deck *decks = this->data->decks;
		card_deck *cards = this->data->cards;
	
		cell gen_start_card = addr_to_card(gen->start - this->data->start);

		cell first_deck = card_deck_for_address(gen->start);
		cell last_deck = card_deck_for_address(gen->end);
	
		cell start = 0, binary_start = 0, end = 0;
	
		for(cell deck_index = first_deck; deck_index < last_deck; deck_index++)
		{
			if(decks[deck_index] & mask)
			{
				this->myvm->gc_stats.decks_scanned++;

				cell first_card = first_card_in_deck(deck_index);
				cell last_card = last_card_in_deck(deck_index);
	
				for(cell card_index = first_card; card_index < last_card; card_index++)
				{
					if(cards[card_index] & mask)
					{
						this->myvm->gc_stats.cards_scanned++;

						if(end < card_start_address(card_index))
						{
							start = gen->find_object_containing_card(card_index - gen_start_card);
							binary_start = start + this->myvm->binary_payload_start((object *)start);
							end = start + this->myvm->untagged_object_size((object *)start);
						}
	
#ifdef FACTOR_DEBUG
						assert(addr_to_card(start - this->data->start) <= card_index);
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
								start = gen->next_object_after(this->myvm,start);
								if(start)
								{
									binary_start = start + this->myvm->binary_payload_start((object *)start);
									end = start + this->myvm->untagged_object_size((object *)start);
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

end:		this->myvm->gc_stats.card_scan_time += (current_micros() - start_time);
	}

	/* Trace all literals referenced from a code block. Only for aging and nursery collections */
	void trace_literal_references(code_block *compiled)
	{
		this->trace_handle(&compiled->owner);
		this->trace_handle(&compiled->literals);
		this->trace_handle(&compiled->relocation);
		this->myvm->gc_stats.code_blocks_scanned++;
	}

	void trace_code_heap_roots(std::set<code_block *> *remembered_set)
	{
		std::set<code_block *>::const_iterator iter = remembered_set->begin();
		std::set<code_block *>::const_iterator end = remembered_set->end();

		for(; iter != end; iter++) trace_literal_references(*iter);
	}

	void cheneys_algorithm()
	{
		while(scan && scan < this->target->here)
		{
			this->trace_slots((object *)scan);
			scan = this->target->next_object_after(this->myvm,scan);
		}
	}
};

}
