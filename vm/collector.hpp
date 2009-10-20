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

		object *untagged = parent->untag<object>(pointer);
		if(!policy.should_copy_p(untagged))
			return;

		object *forwarding = resolve_forwarding(untagged);

		if(forwarding == untagged)
			untagged = promote_object(untagged);
		else if(policy.should_copy_p(forwarding))
			untagged = promote_object(forwarding);
		else
			untagged = forwarding;

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

		for(int i = 0; i < USER_ENV; i++) trace_handle(&parent->userenv[i]);
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
};

}
