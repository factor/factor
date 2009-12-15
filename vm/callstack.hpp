namespace factor
{

inline static cell callstack_size(cell size)
{
	return sizeof(callstack) + size;
}

VM_ASM_API void save_callstack_bottom(stack_frame *callstack_bottom, factor_vm *parent);

/* This is a little tricky. The iterator may allocate memory, so we
keep the callstack in a GC root and use relative offsets */
template<typename Iterator> void factor_vm::iterate_callstack_object(callstack *stack_, Iterator &iterator)
{
	data_root<callstack> stack(stack_,this);
	fixnum frame_offset = untag_fixnum(stack->length) - sizeof(stack_frame);

	while(frame_offset >= 0)
	{
		stack_frame *frame = stack->frame_at(frame_offset);
		frame_offset -= frame->size;
		iterator(frame);
	}
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
