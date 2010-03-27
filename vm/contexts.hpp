namespace factor
{

static const cell context_object_count = 10;

enum context_object {
	OBJ_NAMESTACK,
	OBJ_CATCHSTACK,
};

struct context {

	// First 4 fields accessed directly by compiler. See basis/vm/vm.factor

	/* Factor callstack pointers */
	stack_frame *callstack_top;
	stack_frame *callstack_bottom;

	/* current datastack top pointer */
	cell datastack;

	/* current retain stack top pointer */
	cell retainstack;

	/* C callstack pointer */
	cell callstack_save;

	/* context-specific special objects, accessed by context-object and
	set-context-object primitives */
	cell context_objects[context_object_count];

	segment *datastack_seg;
	segment *retainstack_seg;
	segment *callstack_seg;

	context(cell datastack_size, cell retainstack_size, cell callstack_size);
	~context();

	void reset_datastack();
	void reset_retainstack();
	void reset_callstack();
	void reset_context_objects();
	void reset();

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
		if(datastack + sizeof(cell) < datastack_seg->start
			|| datastack + stack_reserved >= datastack_seg->end)
			reset_datastack();

		if(retainstack + sizeof(cell) < retainstack_seg->start
			|| retainstack + stack_reserved >= retainstack_seg->end)
			reset_retainstack();
	}
};

VM_C_API void begin_callback(factor_vm *vm);
VM_C_API void end_callback(factor_vm *vm);

}
