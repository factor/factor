namespace factor
{

template<typename Visitor> struct slot_visitor {
	factor_vm *parent;
	Visitor visitor;

	explicit slot_visitor<Visitor>(factor_vm *parent_, Visitor visitor_) :
		parent(parent_), visitor(visitor_) {}

	cell visit_pointer(cell pointer);
	void visit_handle(cell *handle);
	void visit_slots(object *ptr, cell payload_start);
	void visit_slots(object *ptr);
	void visit_stack_elements(segment *region, cell *top);
	void visit_data_roots();
	void visit_bignum_roots();
	void visit_roots();
	void visit_contexts();
	void visit_referenced_literals(code_block *compiled);
};

template<typename Visitor>
cell slot_visitor<Visitor>::visit_pointer(cell pointer)
{
	if(immediate_p(pointer)) return pointer;

	object *untagged = untag<object>(pointer);
	untagged = visitor(untagged);
	return RETAG(untagged,TAG(pointer));
}

template<typename Visitor>
void slot_visitor<Visitor>::visit_handle(cell *handle)
{
	*handle = visit_pointer(*handle);
}

template<typename Visitor>
void slot_visitor<Visitor>::visit_slots(object *ptr, cell payload_start)
{
	cell *slot = (cell *)ptr;
	cell *end = (cell *)((cell)ptr + payload_start);

	if(slot != end)
	{
		slot++;
		for(; slot < end; slot++) visit_handle(slot);
	}
}

template<typename Visitor>
void slot_visitor<Visitor>::visit_slots(object *ptr)
{
	visit_slots(ptr,ptr->binary_payload_start());
}

template<typename Visitor>
void slot_visitor<Visitor>::visit_stack_elements(segment *region, cell *top)
{
	for(cell *ptr = (cell *)region->start; ptr <= top; ptr++)
		visit_handle(ptr);
}

template<typename Visitor>
void slot_visitor<Visitor>::visit_data_roots()
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

template<typename Visitor>
void slot_visitor<Visitor>::visit_bignum_roots()
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

template<typename Visitor>
void slot_visitor<Visitor>::visit_roots()
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

template<typename Visitor>
void slot_visitor<Visitor>::visit_contexts()
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

template<typename Visitor>
struct literal_references_visitor {
	slot_visitor<Visitor> *visitor;

	explicit literal_references_visitor(slot_visitor<Visitor> *visitor_) : visitor(visitor_) {}

	void operator()(relocation_entry rel, cell index, code_block *compiled)
	{
		if(rel.rel_type() == RT_IMMEDIATE)
		{
			instruction_operand op(rel.rel_class(),rel.rel_offset() + (cell)(compiled + 1));
			cell literal = op.load_address();
			literal = visitor->visit_pointer(literal);
			op.store_address(literal);
		}
	}
};

template<typename Visitor>
void slot_visitor<Visitor>::visit_referenced_literals(code_block *compiled)
{
	visit_handle(&compiled->owner);
	visit_handle(&compiled->literals);
	visit_handle(&compiled->relocation);

	if(!parent->code->needs_fixup_p(compiled))
	{
		literal_references_visitor<Visitor> visitor(this);
		parent->iterate_relocations(compiled,visitor);
	}
}

}
