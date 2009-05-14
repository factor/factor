namespace factor
{

inline static cell callstack_size(cell size)
{
	return sizeof(callstack) + size;
}

stack_frame *fix_callstack_top(stack_frame *top, stack_frame *bottom);
stack_frame *frame_successor(stack_frame *frame);
code_block *frame_code(stack_frame *frame);
cell frame_executing(stack_frame *frame);
cell frame_scan(stack_frame *frame);
cell frame_type(stack_frame *frame);

PRIMITIVE(callstack);
PRIMITIVE(set_callstack);
PRIMITIVE(callstack_to_array);
PRIMITIVE(innermost_stack_frame_executing);
PRIMITIVE(innermost_stack_frame_scan);
PRIMITIVE(set_innermost_stack_frame_quot);

VM_ASM_API void save_callstack_bottom(stack_frame *callstack_bottom);

template<typename T> void iterate_callstack(cell top, cell bottom, T &iterator)
{
	stack_frame *frame = (stack_frame *)bottom - 1;

	while((cell)frame >= top)
	{
		iterator(frame);
		frame = frame_successor(frame);
	}
}

template<typename T> void iterate_callstack_object(callstack *stack, T &iterator)
{
	iterate_callstack((cell)stack->top(),(cell)stack->bottom(),iterator);
}

}
