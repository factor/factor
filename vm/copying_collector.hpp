namespace factor
{

template<typename TargetGeneration, typename Policy>
struct copying_collector : collector<TargetGeneration,Policy> {
	cell scan;

	explicit copying_collector(factor_vm *myvm_, TargetGeneration *target_, Policy policy_) :
		collector<TargetGeneration,Policy>(myvm_,target_,policy_), scan(target_->here) {}

	template<typename SourceGeneration> void trace_objects_between(SourceGeneration *gen, cell scan, cell *end)
	{
		while(scan && scan < *end)
		{
			this->trace_slots((object *)scan);
			scan = gen->next_object_after(this->myvm,scan);
		}
	}

	template<typename SourceGeneration> void trace_card(SourceGeneration *gen, card *ptr)
	{
		cell card_start = this->myvm->card_to_addr(ptr);
		cell card_scan = card_start + gen->card_offset(card_start);
		cell card_end = this->myvm->card_to_addr(ptr + 1);

		trace_objects_between(gen,card_scan,&card_end);

		this->myvm->gc_stats.cards_scanned++;
	}

	template<typename SourceGeneration> void trace_card_deck(SourceGeneration *gen, card_deck *deck, card mask, card unmask)
	{
		card *first_card = this->myvm->deck_to_card(deck);
		card *last_card = this->myvm->deck_to_card(deck + 1);

		u32 *quad_ptr;
		u32 quad_mask = mask | (mask << 8) | (mask << 16) | (mask << 24);

		for(quad_ptr = (u32 *)first_card; quad_ptr < (u32 *)last_card; quad_ptr++)
		{
			if(*quad_ptr & quad_mask)
			{
				card *ptr = (card *)quad_ptr;

				for(int card = 0; card < 4; card++)
				{
					if(ptr[card] & mask)
					{
						trace_card(gen,&ptr[card]);
						ptr[card] &= ~unmask;
					}
				}
			}
		}

		this->myvm->gc_stats.decks_scanned++;
	}

	template<typename SourceGeneration> void trace_cards(SourceGeneration *gen)
	{
		u64 start = current_micros();

		card_deck *first_deck = this->myvm->addr_to_deck(gen->start);
		card_deck *last_deck = this->myvm->addr_to_deck(gen->end);

		card mask, unmask;

		/* if we are collecting the nursery, we care about old->nursery pointers
		but not old->aging pointers */
		if(this->current_gc->collecting_nursery_p())
		{
			mask = card_points_to_nursery;

			/* after the collection, no old->nursery pointers remain
			anywhere, but old->aging pointers might remain in tenured
			space */
			if(gen->is_tenured_p())
				unmask = card_points_to_nursery;
			/* after the collection, all cards in aging space can be
			cleared */
			else if(gen->is_aging_p())
				unmask = card_mark_mask;
			else
			{
				critical_error("bug in trace_gen_cards",0);
				return;
			}
		}
		/* if we are collecting aging space into tenured space, we care about
		all old->nursery and old->aging pointers. no old->aging pointers can
		remain */
		else if(this->current_gc->collecting_aging_p())
		{
			if(this->current_gc->collecting_aging_again)
			{
				mask = card_points_to_aging;
				unmask = card_mark_mask;
			}
			/* after we collect aging space into the aging semispace, no
			old->nursery pointers remain but tenured space might still have
			pointers to aging space. */
			else
			{
				mask = card_points_to_aging;
				unmask = card_points_to_nursery;
			}
		}
		else
		{
			critical_error("bug in trace_gen_cards",0);
			return;
		}

		for(card_deck *ptr = first_deck; ptr < last_deck; ptr++)
		{
			if(*ptr & mask)
			{
				trace_card_deck(gen,ptr,mask,unmask);
				*ptr &= ~unmask;
			}
		}

		this->myvm->gc_stats.card_scan_time += (current_micros() - start);
	}

	/* Trace all literals referenced from a code block. Only for aging and nursery collections */
	void trace_literal_references(code_block *compiled)
	{
		this->trace_handle(&compiled->owner);
		this->trace_handle(&compiled->literals);
		this->trace_handle(&compiled->relocation);
	}
	
	/* Trace literals referenced from all code blocks. Only for aging and nursery collections */
	void trace_code_heap_roots()
	{
		if(this->current_gc->collecting_gen >= this->myvm->code->youngest_referenced_generation)
		{
			unordered_map<code_block *,cell> &remembered_set = this->myvm->code->remembered_set;
			unordered_map<code_block *,cell>::const_iterator iter = remembered_set.begin();
			unordered_map<code_block *,cell>::const_iterator end = remembered_set.end();
	
			for(; iter != end; iter++)
			{
				if(this->current_gc->collecting_gen >= iter->second)
					trace_literal_references(iter->first);
			}
	
			this->myvm->gc_stats.code_heap_scans++;
		}
	}

	void cheneys_algorithm()
	{
		trace_objects_between(this->target,scan,&this->target->here);
	}
};

}
