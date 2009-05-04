namespace factor
{

inline static CELL callstack_size(CELL size)
{
	return sizeof(F_CALLSTACK) + size;
}

#define FIRST_STACK_FRAME(stack) (F_STACK_FRAME *)((stack) + 1)

typedef void (*CALLSTACK_ITER)(F_STACK_FRAME *frame);

F_STACK_FRAME *fix_callstack_top(F_STACK_FRAME *top, F_STACK_FRAME *bottom);
void iterate_callstack(CELL top, CELL bottom, CALLSTACK_ITER iterator);
void iterate_callstack_object(F_CALLSTACK *stack, CALLSTACK_ITER iterator);
F_STACK_FRAME *frame_successor(F_STACK_FRAME *frame);
F_CODE_BLOCK *frame_code(F_STACK_FRAME *frame);
CELL frame_executing(F_STACK_FRAME *frame);
CELL frame_scan(F_STACK_FRAME *frame);
CELL frame_type(F_STACK_FRAME *frame);

PRIMITIVE(callstack);
PRIMITIVE(set_callstack);
PRIMITIVE(callstack_to_array);
PRIMITIVE(innermost_stack_frame_quot);
PRIMITIVE(innermost_stack_frame_scan);
PRIMITIVE(set_innermost_stack_frame_quot);

VM_ASM_API void save_callstack_bottom(F_STACK_FRAME *callstack_bottom);

}
