namespace factor
{

template<typename Visitor> struct call_frame_code_block_visitor {
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

template<typename Visitor> struct callback_code_block_visitor {
	callback_heap *callbacks;
	Visitor visitor;

	explicit callback_code_block_visitor(callback_heap *callbacks_, Visitor visitor_) :
		callbacks(callbacks_), visitor(visitor_) {}

	void operator()(callback *stub)
	{
		stub->compiled = visitor(stub->compiled);
		callbacks->update(stub);
	}
};

template<typename Visitor> struct code_block_visitor {
	factor_vm *parent;
	Visitor visitor;

	explicit code_block_visitor(factor_vm *parent_, Visitor visitor_) :
		parent(parent_), visitor(visitor_) {}

	void visit_object_code_block(object *obj)
	{
		switch(obj->h.hi_tag())
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

	void visit_context_code_blocks()
	{
		call_frame_code_block_visitor<Visitor> call_frame_visitor(parent,visitor);
		parent->iterate_active_frames(call_frame_visitor);
	}

	void visit_callback_code_blocks()
	{
		callback_code_block_visitor<Visitor> callback_visitor(parent->callbacks,visitor);
		parent->callbacks->iterate(callback_visitor);
	}

};

}
