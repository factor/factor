namespace factor
{

/* Assembly code makes assumptions about the layout of this struct */
struct context {
	/* C stack pointer on entry */
	stack_frame *callstack_top;
	stack_frame *callstack_bottom;

	/* current datastack top pointer */
	cell datastack;

	/* current retain stack top pointer */
	cell retainstack;

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

	cell peek()
	{
		return *(cell *)datastack;
	}

	void replace(cell tagged)
	{
		*(cell *)datastack = tagged;
	}

	cell pop()
	{
		cell value = peek();
		datastack -= sizeof(cell);
		return value;
	}

	void push(cell tagged)
	{
		datastack += sizeof(cell);
		replace(tagged);
	}

	void reset_datastack()
	{
		datastack = datastack_region->start - sizeof(cell);
	}

	void reset_retainstack()
	{
		retainstack = retainstack_region->start - sizeof(cell);
	}

	static const cell stack_reserved = (64 * sizeof(cell));

	void fix_stacks()
	{
		if(datastack + sizeof(cell) < datastack_region->start
			|| datastack + stack_reserved >= datastack_region->end)
			reset_datastack();

		if(retainstack + sizeof(cell) < retainstack_region->start
			|| retainstack + stack_reserved >= retainstack_region->end)
			reset_retainstack();
	}
};

VM_C_API void nest_stacks(stack_frame *magic_frame, factor_vm *vm);
VM_C_API void unnest_stacks(factor_vm *vm);

}
