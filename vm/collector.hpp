namespace factor
{

template<typename TargetGeneration, typename Policy> struct collector {
	factor_vm *myvm;
	data_heap *data;
	code_heap *code;
	gc_state *current_gc;
	TargetGeneration *target;
	Policy policy;

	explicit collector(factor_vm *myvm_, TargetGeneration *target_, Policy policy_) :
		myvm(myvm_),
		data(myvm_->data),
		code(myvm_->code),
		current_gc(myvm_->current_gc),
		target(target_),
		policy(policy_) {}

	object *resolve_forwarding(object *untagged)
	{
		myvm->check_data_pointer(untagged);

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

		object *untagged = myvm->untag<object>(pointer);
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
		cell *end = (cell *)((cell)ptr + myvm->binary_payload_start(ptr));

		if(slot != end)
		{
			slot++;
			for(; slot < end; slot++) trace_handle(slot);
		}
	}

	object *promote_object(object *untagged)
	{
		cell size = myvm->untagged_object_size(untagged);
		object *newpointer = target->allot(size);
		/* XXX not exception-safe */
		if(!newpointer) longjmp(current_gc->gc_unwind,1);

		memcpy(newpointer,untagged,size);
		untagged->h.forward_to(newpointer);

		generation_statistics *stats = &myvm->gc_stats.generations[current_gc->collecting_gen];
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
		std::vector<cell>::const_iterator iter = myvm->gc_locals.begin();
		std::vector<cell>::const_iterator end = myvm->gc_locals.end();

		for(; iter < end; iter++)
			trace_handle((cell *)(*iter));
	}

	void trace_registered_bignums()
	{
		std::vector<cell>::const_iterator iter = myvm->gc_bignums.begin();
		std::vector<cell>::const_iterator end = myvm->gc_bignums.end();

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
		trace_handle(&myvm->T);
		trace_handle(&myvm->bignum_zero);
		trace_handle(&myvm->bignum_pos_one);
		trace_handle(&myvm->bignum_neg_one);

		trace_registered_locals();
		trace_registered_bignums();

		for(int i = 0; i < USER_ENV; i++) trace_handle(&myvm->userenv[i]);
	}

	void trace_contexts()
	{
		context *stacks = myvm->stack_chain;

		while(stacks)
		{
			trace_stack_elements(stacks->datastack_region,(cell *)stacks->datastack);
			trace_stack_elements(stacks->retainstack_region,(cell *)stacks->retainstack);

			trace_handle(&stacks->catchstack_save);
			trace_handle(&stacks->current_callback_save);

			stacks = stacks->next;
		}
	}
};

}
