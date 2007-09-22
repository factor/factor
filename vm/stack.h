/* Assembly code makes assumptions about the layout of this struct:
   - callstack_top field is 0
   - callstack_bottom field is 1
   - datastack field is 2
   - retainstack field is 3 */
typedef struct _F_CONTEXT {
	/* C stack pointer on entry */
	F_STACK_FRAME *callstack_top;
	F_STACK_FRAME *callstack_bottom;

	/* current datastack top pointer */
	CELL datastack;

	/* current retain stack top pointer */
	CELL retainstack;

	/* saved contents of ds register on entry to callback */
	CELL datastack_save;

	/* saved contents of rs register on entry to callback */
	CELL retainstack_save;

	/* memory region holding current datastack */
	F_SEGMENT *datastack_region;

	/* memory region holding current retain stack */
	F_SEGMENT *retainstack_region;

	/* saved userenv slots on entry to callback */
	CELL catchstack_save;
	CELL current_callback_save;

	/* saved extra_roots pointer on entry to callback */
	CELL extra_roots;

	struct _F_CONTEXT *next;
} F_CONTEXT;

DLLEXPORT F_CONTEXT *stack_chain;

CELL ds_size, rs_size;

#define ds_bot (stack_chain->datastack_region->start)
#define ds_top (stack_chain->datastack_region->end)
#define rs_bot (stack_chain->retainstack_region->start)
#define rs_top (stack_chain->retainstack_region->end)

void reset_datastack(void);
void reset_retainstack(void);
void fix_stacks(void);
FASTCALL void save_callstack_bottom(F_STACK_FRAME *callstack_bottom);
DLLEXPORT void save_stacks(void);
DLLEXPORT void nest_stacks(void);
DLLEXPORT void unnest_stacks(void);
void init_stacks(CELL ds_size, CELL rs_size);

#define FIRST_STACK_FRAME(stack) (F_STACK_FRAME *)((stack) + 1)

#define REBASE_FRAME_SUCCESSOR(frame,delta) (F_STACK_FRAME *)((CELL)FRAME_SUCCESSOR(frame) + delta)

typedef void (*CALLSTACK_ITER)(F_STACK_FRAME *frame);

void iterate_callstack(CELL top, CELL bottom, CELL base, CALLSTACK_ITER iterator);
void iterate_callstack_object(F_CALLSTACK *stack, CALLSTACK_ITER iterator);
CELL frame_executing(F_STACK_FRAME *frame);
CELL frame_type(F_STACK_FRAME *frame);

DECLARE_PRIMITIVE(drop);
DECLARE_PRIMITIVE(2drop);
DECLARE_PRIMITIVE(3drop);
DECLARE_PRIMITIVE(dup);
DECLARE_PRIMITIVE(2dup);
DECLARE_PRIMITIVE(3dup);
DECLARE_PRIMITIVE(rot);
DECLARE_PRIMITIVE(_rot);
DECLARE_PRIMITIVE(dupd);
DECLARE_PRIMITIVE(swapd);
DECLARE_PRIMITIVE(nip);
DECLARE_PRIMITIVE(2nip);
DECLARE_PRIMITIVE(tuck);
DECLARE_PRIMITIVE(over);
DECLARE_PRIMITIVE(pick);
DECLARE_PRIMITIVE(swap);
DECLARE_PRIMITIVE(to_r);
DECLARE_PRIMITIVE(from_r);
DECLARE_PRIMITIVE(datastack);
DECLARE_PRIMITIVE(retainstack);
DECLARE_PRIMITIVE(callstack);
DECLARE_PRIMITIVE(set_datastack);
DECLARE_PRIMITIVE(set_retainstack);
DECLARE_PRIMITIVE(set_callstack);
DECLARE_PRIMITIVE(callstack_to_array);
DECLARE_PRIMITIVE(array_to_callstack);
