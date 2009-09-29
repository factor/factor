namespace factor
{

inline static cell callstack_size(cell size)
{
	return sizeof(callstack) + size;
}

VM_ASM_API void save_callstack_bottom(stack_frame *callstack_bottom, factor_vm *vm);

/* This is a little tricky. The iterator may allocate memory, so we
keep the callstack in a GC root and use relative offsets */
template<typename TYPE> void factor_vm::iterate_callstack_object(callstack *stack_, TYPE &iterator)
{
	gc_root<callstack> stack(stack_,this);
	fixnum frame_offset = untag_fixnum(stack->length) - sizeof(stack_frame);

	while(frame_offset >= 0)
	{
		stack_frame *frame = stack->frame_at(frame_offset);
		frame_offset -= frame->size;
		iterator(frame,this);
	}
}

template<typename TYPE> void factor_vm::iterate_callstack(cell top, cell bottom, TYPE &iterator)
{
	stack_frame *frame = (stack_frame *)bottom - 1;

	while((cell)frame >= top)
	{
		iterator(frame,this);
		frame = frame_successor(frame);
	}
}

/* Every object has a regular representation in the runtime, which makes GC
much simpler. Every slot of the object until binary_payload_start is a pointer
to some other object. */
struct factor_vm;
inline void factor_vm::do_slots(cell obj, void (* iter)(cell *,factor_vm*))
{
	cell scan = obj;
	cell payload_start = binary_payload_start((object *)obj);
	cell end = obj + payload_start;

	scan += sizeof(cell);

	while(scan < end)
	{
		iter((cell *)scan,this);
		scan += sizeof(cell);
	}
}

}
