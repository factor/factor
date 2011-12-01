namespace factor
{

inline static cell callstack_object_size(cell size)
{
	return sizeof(callstack) + size;
}

/* This is a little tricky. The iterator may allocate memory, so we
keep the callstack in a GC root and use relative offsets */
template<typename Iterator> void factor_vm::iterate_callstack_object(callstack *stack_, Iterator &iterator)
{
	data_root<callstack> stack(stack_,this);
	fixnum frame_offset = factor::untag_fixnum(stack->length) - sizeof(stack_frame);

	while(frame_offset >= 0)
	{
		stack_frame *frame = stack->frame_at(frame_offset);
		frame_offset -= frame->size;
		iterator(frame);
	}
}

inline void factor_vm::verify_callstack(context *ctx, cell pc)
{
	if (pc == 0)
	{
		std::cout << "null return address" << std::endl;
		return;
	}

	unsigned char *frame_top = (unsigned char*)ctx->callstack_top;
	cell addr = pc;

	while(frame_top < (unsigned char*)ctx->callstack_bottom)
	{
		std::cout << std::endl;
		std::cout << "address " << (void*)addr << std::endl;
		code_block *owner = code->code_block_for_address(addr);
		std::cout << "owner " << (void*)owner->entry_point() << " ";
		print_obj(owner->owner);
		std::cout << std::endl;
		cell frame_size = owner->stack_frame_size_for_address(addr);
		std::cout << "frame size " << (void*)frame_size << std::endl;
		frame_top += frame_size;
		stack_frame *frame = (stack_frame*)frame_top - 1;
		if (owner->entry_point() != frame->entry_point)
		{
			std::cout << "unexpected frame owner " << (void*)frame->entry_point << " ";
			print_obj(((code_block*)frame->entry_point - 1)->owner);
			std::cout << std::endl;
		}
		if (frame_size != frame->size)
			std::cout << "unexpected frame size " << frame->size << std::endl;
		// XXX x86
		addr = *(cell*)frame_top;
	}
}

inline void factor_vm::verify_callstack(context *ctx)
{
	/*
	std::cout << std::endl << std::endl
		<< "callstack " << (void*)ctx->callstack_top
		<< " to " << (void*)ctx->callstack_bottom << std::endl;

	// XXX x86-centric
	cell return_address = *((cell*)ctx->callstack_top);
	verify_callstack(ctx, return_address);
	*/
}

template<typename Iterator> void factor_vm::iterate_callstack(context *ctx, Iterator &iterator)
{
	stack_frame *frame = ctx->callstack_bottom - 1;

	while(frame >= ctx->callstack_top)
	{
		iterator(frame);
		frame = frame_successor(frame);
	}
}

}
