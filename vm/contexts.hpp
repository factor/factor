namespace factor
{

/* Assembly code makes assumptions about the layout of this struct:
   - callstack_top field is 0
   - callstack_bottom field is 1
   - datastack field is 2
   - retainstack field is 3 */
struct context {
	/* C stack pointer on entry */
	stack_frame *callstack_top;
	stack_frame *callstack_bottom;

	/* current datastack top pointer */
	cell datastack;

	/* current retain stack top pointer */
	cell retainstack;

	/* saved contents of ds register on entry to callback */
	cell datastack_save;

	/* saved contents of rs register on entry to callback */
	cell retainstack_save;

	/* memory region holding current datastack */
	segment *datastack_region;

	/* memory region holding current retain stack */
	segment *retainstack_region;

	/* saved userenv slots on entry to callback */
	cell catchstack_save;
	cell current_callback_save;

	context *next;
};

#define ds_bot (stack_chain->datastack_region->start)
#define ds_top (stack_chain->datastack_region->end)
#define rs_bot (stack_chain->retainstack_region->start)
#define rs_top (stack_chain->retainstack_region->end)

DEFPUSHPOP(d,ds)
DEFPUSHPOP(r,rs)

PRIMITIVE(datastack);
PRIMITIVE(retainstack);
PRIMITIVE(set_datastack);
PRIMITIVE(set_retainstack);
PRIMITIVE(check_datastack);

struct factorvm;
VM_C_API void nest_stacks(factorvm *vm);
VM_C_API void unnest_stacks(factorvm *vm);

}

