namespace factor
{

struct full_policy {
	factor_vm *parent;
	tenured_space *tenured;

	explicit full_policy(factor_vm *parent_) : parent(parent_), tenured(parent->data->tenured) {}

	bool should_copy_p(object *untagged)
	{
		return !tenured->contains_p(untagged);
	}

	void promoted_object(object *obj)
	{
		tenured->set_marked_p(obj);
		parent->mark_stack.push_back((cell)obj);
	}

	void visited_object(object *obj)
	{
		if(!tenured->marked_p(obj))
			promoted_object(obj);
	}
};

struct code_workhorse {
	factor_vm *parent;
	code_heap *code;

	explicit code_workhorse(factor_vm *parent_) : parent(parent_), code(parent->code) {}

	code_block *operator()(code_block *compiled)
	{
		if(!code->marked_p(compiled))
		{
			code->set_marked_p(compiled);
			parent->mark_stack.push_back((cell)compiled + 1);
		}

		return compiled;
	}
};

struct full_collector : collector<tenured_space,full_policy> {
	code_block_visitor<code_workhorse> code_visitor;

	explicit full_collector(factor_vm *parent_);
	void trace_code_block(code_block *compiled);
	void trace_context_code_blocks();
	void trace_object_code_block(object *obj);
};

}
