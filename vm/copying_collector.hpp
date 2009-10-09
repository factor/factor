namespace factor
{

struct dummy_unmarker {
	void operator()(bool result, card *ptr) {}
};

struct simple_unmarker {
	card unmask;
	simple_unmarker(card unmask_) : unmask(unmask_) {}
	void operator()(bool result, card *ptr) { *ptr &= ~unmask; }
};

struct complex_unmarker {
	card unmask_none, unmask_some;
	complex_unmarker(card unmask_none_, card unmask_some_) :
		unmask_none(unmask_none_), unmask_some(unmask_some_) {}

	void operator()(bool result, card *ptr)
	{
		*ptr &= (result ? ~unmask_some : ~unmask_none);
	}
};

template<typename TargetGeneration, typename Policy>
struct copying_collector : collector<TargetGeneration,Policy> {
	cell scan;

	explicit copying_collector(factor_vm *myvm_, TargetGeneration *target_, Policy policy_) :
		collector<TargetGeneration,Policy>(myvm_,target_,policy_), scan(target_->here) {}

	template<typename SourceGeneration>
	bool trace_objects_between(SourceGeneration *gen, cell scan, cell *end)
	{
		bool copied = false;

		while(scan && scan < *end)
		{
			copied |= this->trace_slots((object *)scan);
			scan = gen->next_object_after(this->myvm,scan);
		}

		return copied;
	}

	inline cell card_index(cell deck)
	{
		return deck << (deck_bits - card_bits);
	}

	inline cell card_deck_index(cell a)
	{
		return (a - this->data->start) >> deck_bits;
	}

	inline cell card_start_address(cell card)
	{
		return (card << card_bits) + this->data->start;
	}

	template<typename SourceGeneration, typename Unmarker>
	bool trace_card(SourceGeneration *gen, card *cards, cell card_index, Unmarker unmarker)
	{
		cell card_start = card_start_address(card_index);
		cell card_scan = card_start + gen->first_object_in_card(card_start);
		cell card_end = card_start_address(card_index + 1);

		bool result = this->trace_objects_between(gen,card_scan,&card_end);
		unmarker(result,&cards[card_index]);

		this->myvm->gc_stats.cards_scanned++;

		return result;
	}

	template<typename SourceGeneration, typename Unmarker>
	bool trace_card_deck(SourceGeneration *gen, cell deck_index, card mask, Unmarker unmarker)
	{
		cell first_card = card_index(deck_index);
		cell last_card = card_index(deck_index + 1);

		bool copied = false;

		card *cards = this->data->cards;
		for(cell i = first_card; i < last_card; i++)
		{
			if(cards[i] & mask) copied |= trace_card(gen,cards,i,unmarker);
		}

		this->myvm->gc_stats.decks_scanned++;

		return copied;
	}

	template<typename SourceGeneration, typename Unmarker>
	void trace_cards(SourceGeneration *gen, card mask, Unmarker unmarker)
	{
		u64 start = current_micros();

		cell first_deck = card_deck_index(gen->start);
		cell last_deck = card_deck_index(gen->end);

		card_deck *decks = this->data->decks;
		for(cell i = first_deck; i < last_deck; i++)
		{
			if(decks[i] & mask)
				unmarker(trace_card_deck(gen,i,mask,unmarker),&decks[i]);
		}

		this->myvm->gc_stats.card_scan_time += (current_micros() - start);
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
		trace_objects_between(this->target,scan,&this->target->here);
	}
};

}
