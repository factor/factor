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

	/* callback-bottom stack frame, or NULL for top-level context.
	When nest_stacks() is called, callstack layout with callbacks
	is as follows:
	
	[ C function ]
	[ callback stub in code heap ] <-- this is the magic frame
	[ native frame: c_to_factor() ]
	[ callback quotation frame ] <-- first call frame in call stack
	
	magic frame is retained so that it's XT can be traced and forwarded. */
	stack_frame *magic_frame;

	/* memory region holding current datastack */
	segment *datastack_region;

	/* memory region holding current retain stack */
	segment *retainstack_region;

	/* saved special_objects slots on entry to callback */
	cell catchstack_save;
	cell current_callback_save;

	context *next;

	context(cell ds_size, cell rs_size);
};

#define ds_bot (ctx->datastack_region->start)
#define ds_top (ctx->datastack_region->end)
#define rs_bot (ctx->retainstack_region->start)
#define rs_top (ctx->retainstack_region->end)

inline cell dpeek()
{
	return *(cell *)ds;
}

inline void drepl(cell tagged)
{
	*(cell *)ds = tagged;
}

inline cell dpop()
{
	cell value = dpeek();
	ds -= sizeof(cell);
	return value;
}

inline void dpush(cell tagged)
{
	ds += sizeof(cell);
	drepl(tagged);
}

VM_C_API void nest_stacks(stack_frame *magic_frame, factor_vm *vm);
VM_C_API void unnest_stacks(factor_vm *vm);

}
