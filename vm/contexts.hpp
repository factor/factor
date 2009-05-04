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

extern cell ds_size, rs_size;

#define ds_bot (stack_chain->datastack_region->start)
#define ds_top (stack_chain->datastack_region->end)
#define rs_bot (stack_chain->retainstack_region->start)
#define rs_top (stack_chain->retainstack_region->end)

DEFPUSHPOP(d,ds)
DEFPUSHPOP(r,rs)

void reset_datastack(void);
void reset_retainstack(void);
void fix_stacks(void);
void init_stacks(cell ds_size, cell rs_size);

PRIMITIVE(datastack);
PRIMITIVE(retainstack);
PRIMITIVE(set_datastack);
PRIMITIVE(set_retainstack);
PRIMITIVE(check_datastack);

VM_C_API void save_stacks(void);
VM_C_API void nest_stacks(void);
VM_C_API void unnest_stacks(void);

}

VM_C_API factor::context *stack_chain;
