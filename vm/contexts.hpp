namespace factor
{

static const cell context_object_count = 10;

enum context_object {
	OBJ_NAMESTACK,
	OBJ_CATCHSTACK,
	OBJ_CONTEXT_ID,
};

/* Assembly code makes assumptions about the layout of this struct */
struct context {
	/* C stack pointer on entry */
	stack_frame *callstack_top;
	stack_frame *callstack_bottom;

	/* current datastack top pointer */
	cell datastack;

	/* current retain stack top pointer */
	cell retainstack;

	/* memory region holding current datastack */
	segment *datastack_region;

	/* memory region holding current retain stack */
	segment *retainstack_region;

	/* context-specific special objects, accessed by context-object and
	set-context-object primitives */
	cell context_objects[context_object_count];

	context *next;

	context(cell ds_size, cell rs_size);
	void reset_datastack();
	void reset_retainstack();
	void reset_context_objects();

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

VM_C_API void nest_stacks(factor_vm *vm);
VM_C_API void unnest_stacks(factor_vm *vm);

}
