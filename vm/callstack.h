F_FASTCALL void save_callstack_bottom(F_STACK_FRAME *callstack_bottom);

#define FIRST_STACK_FRAME(stack) (F_STACK_FRAME *)((stack) + 1)

#define FRAME_SUCCESSOR(frame) (frame)->next
#define REBASE_FRAME_SUCCESSOR(frame,delta) (F_STACK_FRAME *)((CELL)FRAME_SUCCESSOR(frame) + delta)

typedef void (*CALLSTACK_ITER)(F_STACK_FRAME *frame);

void iterate_callstack(CELL top, CELL bottom, CELL base, CALLSTACK_ITER iterator);
void iterate_callstack_object(F_CALLSTACK *stack, CALLSTACK_ITER iterator);
CELL frame_executing(F_STACK_FRAME *frame);
CELL frame_type(F_STACK_FRAME *frame);

DECLARE_PRIMITIVE(callstack);
DECLARE_PRIMITIVE(set_datastack);
DECLARE_PRIMITIVE(set_retainstack);
DECLARE_PRIMITIVE(set_callstack);
DECLARE_PRIMITIVE(callstack_to_array);
DECLARE_PRIMITIVE(innermost_stack_frame_quot);
DECLARE_PRIMITIVE(innermost_stack_frame_scan);
DECLARE_PRIMITIVE(set_innermost_stack_frame_quot);
