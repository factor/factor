INLINE CELL callstack_size(CELL size)
{
	return sizeof(F_CALLSTACK) + size;
}

DEFINE_UNTAG(F_CALLSTACK,CALLSTACK_TYPE,callstack)

F_FASTCALL void save_callstack_bottom(F_STACK_FRAME *callstack_bottom);

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

void primitive_callstack(void);
void primitive_set_callstack(void);
void primitive_callstack_to_array(void);
void primitive_innermost_stack_frame_quot(void);
void primitive_innermost_stack_frame_scan(void);
void primitive_set_innermost_stack_frame_quot(void);
