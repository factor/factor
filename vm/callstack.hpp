namespace factor
{

inline static cell callstack_size(cell size)
{
	return sizeof(callstack) + size;
}

#define FIRST_STACK_FRAME(stack) (stack_frame *)((stack) + 1)

typedef void (*CALLSTACK_ITER)(stack_frame *frame);

stack_frame *fix_callstack_top(stack_frame *top, stack_frame *bottom);
void iterate_callstack(cell top, cell bottom, CALLSTACK_ITER iterator);
void iterate_callstack_object(callstack *stack, CALLSTACK_ITER iterator);
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

}
