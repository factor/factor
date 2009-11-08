namespace factor
{

template<typename Visitor> struct slot_visitor {
	factor_vm *parent;
	Visitor visitor;

	explicit slot_visitor<Visitor>(factor_vm *parent_, Visitor visitor_) :
		parent(parent_), visitor(visitor_) {}

	void visit_handle(cell *handle)
	{
		cell pointer = *handle;
		if(immediate_p(pointer)) return;

		object *untagged = untag<object>(pointer);
		untagged = visitor(untagged);
		*handle = RETAG(untagged,TAG(pointer));
	}

	void visit_slots(object *ptr, cell payload_start)
	{
		cell *slot = (cell *)ptr;
		cell *end = (cell *)((cell)ptr + payload_start);

		if(slot != end)
		{
			slot++;
			for(; slot < end; slot++) visit_handle(slot);
		}
	}

	void visit_slots(object *ptr)
	{
		visit_slots(ptr,ptr->binary_payload_start());
	}

	void visit_stack_elements(segment *region, cell *top)
	{
		for(cell *ptr = (cell *)region->start; ptr <= top; ptr++)
			visit_handle(ptr);
	}

	void visit_data_roots()
	{
		std::vector<data_root_range>::const_iterator iter = parent->data_roots.begin();
		std::vector<data_root_range>::const_iterator end = parent->data_roots.end();

		for(; iter < end; iter++)
		{
			data_root_range r = *iter;
			for(cell index = 0; index < r.len; index++)
				visit_handle(r.start + index);
		}
	}

	void visit_bignum_roots()
	{
		std::vector<cell>::const_iterator iter = parent->bignum_roots.begin();
		std::vector<cell>::const_iterator end = parent->bignum_roots.end();

		for(; iter < end; iter++)
		{
			cell *handle = (cell *)(*iter);

			if(*handle)
				*handle = (cell)visitor(*(object **)handle);
		}
	}

	void visit_roots()
	{
		visit_handle(&parent->true_object);
		visit_handle(&parent->bignum_zero);
		visit_handle(&parent->bignum_pos_one);
		visit_handle(&parent->bignum_neg_one);

		visit_data_roots();
		visit_bignum_roots();

		for(cell i = 0; i < special_object_count; i++)
			visit_handle(&parent->special_objects[i]);
	}

	void visit_contexts()
	{
		context *ctx = parent->ctx;

		while(ctx)
		{
			visit_stack_elements(ctx->datastack_region,(cell *)ctx->datastack);
			visit_stack_elements(ctx->retainstack_region,(cell *)ctx->retainstack);

			visit_handle(&ctx->catchstack_save);
			visit_handle(&ctx->current_callback_save);

			ctx = ctx->next;
		}
	}

	void visit_literal_references(code_block *compiled)
	{
		visit_handle(&compiled->owner);
		visit_handle(&compiled->literals);
		visit_handle(&compiled->relocation);
	}
};

}
