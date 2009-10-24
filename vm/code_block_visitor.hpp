namespace factor
{

template<typename Visitor> struct call_frame_code_block_visitor {
	Visitor visitor;

	explicit call_frame_code_block_visitor(Visitor visitor_) : visitor(visitor_) {}

	void operator()(stack_frame *frame)
	{
		cell offset = (cell)FRAME_RETURN_ADDRESS(frame,parent) - (cell)frame->xt;

		code_block *new_block = visitor.visit_code_block(parent->frame_code(frame));
		frame->xt = new_block->xt();

		FRAME_RETURN_ADDRESS(frame,parent) = (void *)((cell)frame->xt + offset);
	}
};

template<typename Visitor> void factor_vm::visit_object_code_block(object *obj, Visitor visitor)
{
	switch(obj->h.hi_tag())
	{
	case WORD_TYPE:
		{
			word *w = (word *)obj;
			if(w->code)
				w->code = visitor.visit_code_block(w->code);
			if(w->profiling)
				w->code = visitor.visit_code_block(w->profiling);

			update_word_xt(obj);
			break;
		}
	case QUOTATION_TYPE:
		{
			quotation *q = (quotation *)obj;
			if(q->code)
				set_quot_xt(visitor.visit_code_block(q->code));
			break;
		}
	case CALLSTACK_TYPE:
		{
			callstack *stack = (callstack *)obj;
			call_frame_code_block_visitor<Visitor> call_frame_visitor(visitor);
			iterate_callstack_object(stack,call_frame_visitor);
			break;
		}
	}
}

template<typename Visitor> void factor_vm::visit_context_code_blocks(Visitor visitor)
{
	callstack *stack = (callstack *)obj;
	call_frame_code_block_visitor<Visitor> call_frame_visitor(visitor);
	iterate_active_frames(call_frame_visitor);
}

template<typename Visitor> struct callback_code_block_visitor {
	callback_heap *callbacks;
	Visitor visitor;

	explicit callback_code_block_visitor(callback_heap *callbacks_, Visitor visitor_) :
		callbacks(callbacks_), visitor(visitor_) {}

	void operator()(callback *stub)
	{
		stub->compiled = visitor.visit_code_block(stub->compiled);
		callbacks->update(stub);
	}
};

template<typename Visitor> void factor_vm::visit_callback_code_blocks(Visitor visitor)
{
	callback_code_block_visitor callback_visitor(callbacks,visitor);
	callbacks->iterate(callback_visitor);
}

}
