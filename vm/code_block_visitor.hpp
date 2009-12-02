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
 
template<typename Visitor> struct code_block_visitor {
	factor_vm *parent;
	Visitor visitor;

	explicit code_block_visitor(factor_vm *parent_, Visitor visitor_) :
		parent(parent_), visitor(visitor_) {}

	code_block *visit_code_block(code_block *compiled);
	void visit_object_code_block(object *obj);
	void visit_embedded_code_pointers(code_block *compiled);
	void visit_context_code_blocks();
};

template<typename Visitor>
code_block *code_block_visitor<Visitor>::visit_code_block(code_block *compiled)
{
	return visitor(compiled);
}

template<typename Visitor>
struct call_frame_code_block_visitor {
	factor_vm *parent;
	Visitor visitor;

	explicit call_frame_code_block_visitor(factor_vm *parent_, Visitor visitor_) :
		parent(parent_), visitor(visitor_) {}

	void operator()(stack_frame *frame)
	{
		cell offset = (cell)FRAME_RETURN_ADDRESS(frame,parent) - (cell)frame->xt;

		code_block *new_block = visitor(parent->frame_code(frame));
		frame->xt = new_block->xt();

		FRAME_RETURN_ADDRESS(frame,parent) = (void *)((cell)frame->xt + offset);
	}
};

template<typename Visitor>
void code_block_visitor<Visitor>::visit_object_code_block(object *obj)
{
	switch(obj->type())
	{
	case WORD_TYPE:
		{
			word *w = (word *)obj;
			if(w->code)
				w->code = visitor(w->code);
			if(w->profiling)
				w->profiling = visitor(w->profiling);

			parent->update_word_xt(w);
			break;
		}
	case QUOTATION_TYPE:
		{
			quotation *q = (quotation *)obj;
			if(q->code)
				parent->set_quot_xt(q,visitor(q->code));
			else
				q->xt = (void *)lazy_jit_compile;
			break;
		}
	case CALLSTACK_TYPE:
		{
			callstack *stack = (callstack *)obj;
			call_frame_code_block_visitor<Visitor> call_frame_visitor(parent,visitor);
			parent->iterate_callstack_object(stack,call_frame_visitor);
			break;
		}
	}
}

template<typename Visitor>
struct embedded_code_pointers_visitor {
	Visitor visitor;

	explicit embedded_code_pointers_visitor(Visitor visitor_) : visitor(visitor_) {}

	void operator()(instruction_operand op)
	{
		relocation_type type = op.rel_type();
		if(type == RT_XT || type == RT_XT_PIC || type == RT_XT_PIC_TAIL)
			op.store_code_block(visitor(op.load_code_block()));
	}
};

template<typename Visitor>
void code_block_visitor<Visitor>::visit_embedded_code_pointers(code_block *compiled)
{
	if(!parent->code->needs_fixup_p(compiled))
	{
		embedded_code_pointers_visitor<Visitor> visitor(this->visitor);
		compiled->each_instruction_operand(visitor);
	}
}

template<typename Visitor>
void code_block_visitor<Visitor>::visit_context_code_blocks()
{
	call_frame_code_block_visitor<Visitor> call_frame_visitor(parent,visitor);
	parent->iterate_active_frames(call_frame_visitor);
}

}
