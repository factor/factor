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

	void operator()(bool result, card *ptr) {
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

	template<typename SourceGeneration, typename Unmarker>
	bool trace_card(SourceGeneration *gen, card *ptr, Unmarker unmarker)
	{
		cell card_start = this->myvm->card_to_addr(ptr);
		cell card_scan = card_start + gen->card_offset(card_start);
		cell card_end = this->myvm->card_to_addr(ptr + 1);

		bool result = this->trace_objects_between(gen,card_scan,&card_end);
		unmarker(result,ptr);

		this->myvm->gc_stats.cards_scanned++;

		return result;
	}

	template<typename SourceGeneration, typename Unmarker>
	bool trace_card_deck(SourceGeneration *gen, card_deck *deck, card mask, Unmarker unmarker)
	{
		card *first_card = this->myvm->deck_to_card(deck);
		card *last_card = this->myvm->deck_to_card(deck + 1);

		u32 *quad_ptr;
		u32 quad_mask = mask | (mask << 8) | (mask << 16) | (mask << 24);

		bool copied = false;

		for(quad_ptr = (u32 *)first_card; quad_ptr < (u32 *)last_card; quad_ptr++)
		{
			if(*quad_ptr & quad_mask)
			{
				card *ptr = (card *)quad_ptr;

				if(ptr[0] & mask) copied |= trace_card(gen,&ptr[0],unmarker);
				if(ptr[1] & mask) copied |= trace_card(gen,&ptr[1],unmarker);
				if(ptr[2] & mask) copied |= trace_card(gen,&ptr[2],unmarker);
				if(ptr[3] & mask) copied |= trace_card(gen,&ptr[3],unmarker);
			}
		}

		this->myvm->gc_stats.decks_scanned++;

		return copied;
	}

	template<typename SourceGeneration, typename Unmarker>
	void trace_cards(SourceGeneration *gen, cell mask, Unmarker unmarker)
	{
		u64 start = current_micros();

		card_deck *first_deck = this->myvm->addr_to_deck(gen->start);
		card_deck *last_deck = this->myvm->addr_to_deck(gen->end);

		for(card_deck *ptr = first_deck; ptr < last_deck; ptr++)
		{
			if(*ptr & mask)
				unmarker(trace_card_deck(gen,ptr,mask,unmarker),ptr);
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
