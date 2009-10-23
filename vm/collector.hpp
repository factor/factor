namespace factor
{

template<typename TargetGeneration, typename Policy> struct collector {
	factor_vm *parent;
	data_heap *data;
	code_heap *code;
	gc_state *current_gc;
	generation_statistics *stats;
	TargetGeneration *target;
	Policy policy;

	explicit collector(factor_vm *parent_, generation_statistics *stats_, TargetGeneration *target_, Policy policy_) :
		parent(parent_),
		data(parent_->data),
		code(parent_->code),
		current_gc(parent_->current_gc),
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

	void trace_handle(cell *handle)
	{
		cell pointer = *handle;

		if(immediate_p(pointer)) return;

		object *untagged = untag<object>(pointer);
		if(!policy.should_copy_p(untagged))
		{
			policy.visited_object(untagged);
			return;
		}

		object *forwarding = resolve_forwarding(untagged);

		if(forwarding == untagged)
			untagged = promote_object(untagged);
		else if(policy.should_copy_p(forwarding))
			untagged = promote_object(forwarding);
		else
		{
			untagged = forwarding;
			policy.visited_object(untagged);
		}

		*handle = RETAG(untagged,TAG(pointer));
	}

	void trace_slots(object *ptr)
	{
		cell *slot = (cell *)ptr;
		cell *end = (cell *)((cell)ptr + parent->binary_payload_start(ptr));

		if(slot != end)
		{
			slot++;
			for(; slot < end; slot++) trace_handle(slot);
		}
	}

	object *promote_object(object *untagged)
	{
		cell size = untagged->size();
		object *newpointer = target->allot(size);
		/* XXX not exception-safe */
		if(!newpointer) longjmp(current_gc->gc_unwind,1);

		memcpy(newpointer,untagged,size);
		untagged->h.forward_to(newpointer);

		stats->object_count++;
		stats->bytes_copied += size;

		policy.promoted_object(newpointer);

		return newpointer;
	}

	void trace_stack_elements(segment *region, cell *top)
	{
		for(cell *ptr = (cell *)region->start; ptr <= top; ptr++)
			trace_handle(ptr);
	}

	void trace_registered_locals()
	{
		std::vector<cell>::const_iterator iter = parent->gc_locals.begin();
		std::vector<cell>::const_iterator end = parent->gc_locals.end();

		for(; iter < end; iter++)
			trace_handle((cell *)(*iter));
	}

	void trace_registered_bignums()
	{
		std::vector<cell>::const_iterator iter = parent->gc_bignums.begin();
		std::vector<cell>::const_iterator end = parent->gc_bignums.end();

		for(; iter < end; iter++)
		{
			cell *handle = (cell *)(*iter);

			if(*handle)
			{
				*handle |= BIGNUM_TYPE;
				trace_handle(handle);
				*handle &= ~BIGNUM_TYPE;
			}
		}
	}

	/* Copy roots over at the start of GC, namely various constants, stacks,
	the user environment and extra roots registered by local_roots.hpp */
	void trace_roots()
	{
		trace_handle(&parent->true_object);
		trace_handle(&parent->bignum_zero);
		trace_handle(&parent->bignum_pos_one);
		trace_handle(&parent->bignum_neg_one);

		trace_registered_locals();
		trace_registered_bignums();

		for(cell i = 0; i < special_object_count; i++)
			trace_handle(&parent->special_objects[i]);
	}

	void trace_contexts()
	{
		context *ctx = parent->ctx;

		while(ctx)
		{
			trace_stack_elements(ctx->datastack_region,(cell *)ctx->datastack);
			trace_stack_elements(ctx->retainstack_region,(cell *)ctx->retainstack);

			trace_handle(&ctx->catchstack_save);
			trace_handle(&ctx->current_callback_save);

			ctx = ctx->next;
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
				this->parent->gc_stats.decks_scanned++;

				cell first_card = first_card_in_deck(deck_index);
				cell last_card = last_card_in_deck(deck_index);
	
				for(cell card_index = first_card; card_index < last_card; card_index++)
				{
					if(cards[card_index] & mask)
					{
						this->parent->gc_stats.cards_scanned++;

						if(end < card_start_address(card_index))
						{
							start = gen->starts.find_object_containing_card(card_index - gen_start_card);
							binary_start = start + this->parent->binary_payload_start((object *)start);
							end = start + ((object *)start)->size();
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
								start = gen->next_object_after(start);
								if(start)
								{
									binary_start = start + this->parent->binary_payload_start((object *)start);
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

end:		this->parent->gc_stats.card_scan_time += (current_micros() - start_time);
	}

	/* Trace all literals referenced from a code block. Only for aging and nursery collections */
	void trace_literal_references(code_block *compiled)
	{
		this->trace_handle(&compiled->owner);
		this->trace_handle(&compiled->literals);
		this->trace_handle(&compiled->relocation);
		this->parent->gc_stats.code_blocks_scanned++;
	}

	void trace_code_heap_roots(std::set<code_block *> *remembered_set)
	{
		std::set<code_block *>::const_iterator iter = remembered_set->begin();
		std::set<code_block *>::const_iterator end = remembered_set->end();

		for(; iter != end; iter++) trace_literal_references(*iter);
	}
};

}
