namespace factor
{

/* Code block visitors iterate over sets of code blocks, applying a functor to
each one. The functor returns a new code_block pointer, which may or may not
equal the old one. This is stored back to the original location.

This is used by GC's sweep and compact phases, and the implementation of the
modify-code-heap primitive.

Iteration is driven by visit_*() methods. Some of them define GC roots:
- visit_context_code_blocks()
- visit_callback_code_blocks() */
 
template<typename Fixup> struct code_block_visitor {
	factor_vm *parent;
	Fixup fixup;

	explicit code_block_visitor(factor_vm *parent_, Fixup fixup_) :
		parent(parent_), fixup(fixup_) {}

	code_block *visit_code_block(code_block *compiled);
	void visit_object_code_block(object *obj);
	void visit_embedded_code_pointers(code_block *compiled);
	void visit_context_code_blocks();
	void visit_uninitialized_code_blocks();

	void visit_code_roots();
};

template<typename Fixup>
code_block *code_block_visitor<Fixup>::visit_code_block(code_block *compiled)
{
	return fixup.fixup_code(compiled);
}

template<typename Fixup>
struct call_frame_code_block_visitor {
	factor_vm *parent;
	Fixup fixup;

	explicit call_frame_code_block_visitor(factor_vm *parent_, Fixup fixup_) :
		parent(parent_), fixup(fixup_) {}

	void operator()(void *frame_top, code_block *owner, void *addr)
	{
		set_frame_return_address(frame_top, addr);
		// XXX remove this when prolog data is removed
		cell frame_size = owner->stack_frame_size_for_address((cell)addr);
		stack_frame *frame = (stack_frame*)((char*)frame_top + frame_size) - 1;
		frame->entry_point = owner->entry_point();
	}
};

template<typename Fixup>
void code_block_visitor<Fixup>::visit_object_code_block(object *obj)
{
	switch(obj->type())
	{
	case WORD_TYPE:
		{
			word *w = (word *)obj;
			if(w->entry_point)
				w->entry_point = visit_code_block(w->code())->entry_point();
			break;
		}
	case QUOTATION_TYPE:
		{
			quotation *q = (quotation *)obj;
			if(q->entry_point)
				q->entry_point = visit_code_block(q->code())->entry_point();
			break;
		}
	case CALLSTACK_TYPE:
		{
			callstack *stack = (callstack *)obj;
			call_frame_code_block_visitor<Fixup> call_frame_visitor(parent,fixup);
			parent->iterate_callstack_object_reversed(stack,call_frame_visitor,fixup);
			break;
		}
	}
}

template<typename Fixup>
struct embedded_code_pointers_visitor {
	Fixup fixup;

	explicit embedded_code_pointers_visitor(Fixup fixup_) : fixup(fixup_) {}

	void operator()(instruction_operand op)
	{
		relocation_type type = op.rel_type();
		if(type == RT_ENTRY_POINT
			|| type == RT_ENTRY_POINT_PIC
			|| type == RT_ENTRY_POINT_PIC_TAIL)
			op.store_code_block(fixup.fixup_code(op.load_code_block()));
	}
};

template<typename Fixup>
void code_block_visitor<Fixup>::visit_embedded_code_pointers(code_block *compiled)
{
	if(!parent->code->uninitialized_p(compiled))
	{
		embedded_code_pointers_visitor<Fixup> operand_visitor(fixup);
		compiled->each_instruction_operand(operand_visitor);
	}
}

template<typename Fixup>
void code_block_visitor<Fixup>::visit_context_code_blocks()
{
	call_frame_code_block_visitor<Fixup> call_frame_visitor(parent,fixup);
	parent->iterate_active_callstacks_reversed(call_frame_visitor,fixup);
}

template<typename Fixup>
void code_block_visitor<Fixup>::visit_uninitialized_code_blocks()
{
	std::map<code_block *, cell> *uninitialized_blocks = &parent->code->uninitialized_blocks;
	std::map<code_block *, cell>::const_iterator iter = uninitialized_blocks->begin();
	std::map<code_block *, cell>::const_iterator end = uninitialized_blocks->end();

	std::map<code_block *, cell> new_uninitialized_blocks;
	for(; iter != end; iter++)
	{
		new_uninitialized_blocks.insert(std::make_pair(
			fixup.fixup_code(iter->first),
			iter->second));
	}

	parent->code->uninitialized_blocks = new_uninitialized_blocks;
}

template<typename Fixup>
void code_block_visitor<Fixup>::visit_code_roots()
{
	visit_uninitialized_code_blocks();
}

}
