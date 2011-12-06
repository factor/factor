namespace factor
{

inline static cell callstack_object_size(cell size)
{
	return sizeof(callstack) + size;
}

/* This is a little tricky. The iterator may allocate memory, so we
keep the callstack in a GC root and use relative offsets */
template<typename Iterator, typename Fixup>
inline void factor_vm::iterate_callstack_object_reversed(callstack *stack_,
	Iterator &iterator, Fixup &fixup)
{
	data_root<callstack> stack(stack_,this);
	fixnum frame_length = factor::untag_fixnum(stack->length);
	fixnum frame_offset = 0;

	while(frame_offset < frame_length)
	{
		void *frame_top = stack->frame_top_at(frame_offset);
		void *addr = frame_return_address(frame_top);

		void *fixed_addr = Fixup::translated_code_block_map
			? (void*)fixup.translate_code((code_block*)addr)
			: addr;
		code_block *owner = code->code_block_for_address((cell)fixed_addr);
		cell frame_size = owner->stack_frame_size_for_address((cell)fixed_addr);

#ifdef FACTOR_DEBUG
		// check our derived owner and frame size against the ones stored in the frame
		// by the function prolog
		stack_frame *frame = (stack_frame*)((char*)frame_top + frame_size) - 1;
		void *fixed_entry_point =
			(void*)fixup.translate_code((code_block*)frame->entry_point);
		FACTOR_ASSERT(owner->entry_point() == fixed_entry_point);
		FACTOR_ASSERT(frame_size == frame->size);
#endif

		iterator(frame_top, frame_size, owner, fixed_addr);
		frame_offset += frame_size;
	}
}

template<typename Iterator>
inline void factor_vm::iterate_callstack_object_reversed(callstack *stack_, Iterator &iterator)
{
	no_fixup none;
	iterate_callstack_object_reversed(stack_, iterator, none);
}

template<typename Iterator, typename Fixup>
inline void factor_vm::iterate_callstack_reversed(context *ctx, Iterator &iterator, Fixup &fixup)
{
	if (ctx->callstack_top == ctx->callstack_bottom)
		return;

	char *frame_top = (char*)ctx->callstack_top;

	while (frame_top < (char*)ctx->callstack_bottom)
	{
		void *addr = frame_return_address((void*)frame_top);
		FACTOR_ASSERT(addr != 0);
		void *fixed_addr = Fixup::translated_code_block_map
			? (void*)fixup.translate_code((code_block*)addr)
			: addr;

		code_block *owner = code->code_block_for_address((cell)fixed_addr);
		code_block *fixed_owner = Fixup::translated_code_block_map
			? owner
			: fixup.translate_code(owner);

		cell frame_size = fixed_owner->stack_frame_size_for_address((cell)fixed_addr);

#ifdef FACTOR_DEBUG
		// check our derived owner and frame size against the ones stored in the frame
		// by the function prolog
		stack_frame *frame = (stack_frame*)(frame_top + frame_size) - 1;
		void *fixed_entry_point = Fixup::translated_code_block_map
			? (void*)fixup.translate_code((code_block*)frame->entry_point)
			: frame->entry_point;
		FACTOR_ASSERT(owner->entry_point() == fixed_entry_point);
		FACTOR_ASSERT(frame_size == frame->size);
#endif
		void *fixed_addr_for_iter = Fixup::translated_code_block_map
			? fixed_addr
			: addr;

		iterator(frame_top, frame_size, owner, fixed_addr_for_iter);
		frame_top += frame_size;
	}
}

template<typename Iterator>
inline void factor_vm::iterate_callstack_reversed(context *ctx, Iterator &iterator)
{
	no_fixup none;
	iterate_callstack_reversed(ctx, iterator, none);
}


}
