#include "factor.h"

void reset_datastack(void)
{
	ds = ds_bot - CELLS;
}

void reset_callstack(void)
{
	cs = cs_bot - CELLS;
}

void fix_stacks(void)
{
	if(STACK_UNDERFLOW(ds,ds_bot))
		reset_datastack();
	else if(STACK_OVERFLOW(ds,ds_bot,ds_size))
		reset_datastack();
	else if(STACK_UNDERFLOW(cs,cs_bot))
		reset_callstack();
	else if(STACK_OVERFLOW(cs,cs_bot,cs_size))
		reset_callstack();
}

void init_stacks(CELL ds_size_, CELL cs_size_)
{
	ds_size = ds_size_;
	cs_size = cs_size_;
	ds_bot = (CELL)alloc_guarded(ds_size);
	reset_datastack();
	cs_bot = (CELL)alloc_guarded(cs_size);
	reset_callstack();
	callframe = userenv[BOOT_ENV];
}

void primitive_drop(void)
{
	dpop();
}

void primitive_dup(void)
{
	dpush(dpeek());
}

void primitive_swap(void)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS);
	put(ds,next);
	put(ds - CELLS,top);
}

void primitive_over(void)
{
	dpush(get(ds - CELLS));
}

void primitive_pick(void)
{
	dpush(get(ds - CELLS * 2));
}

void primitive_to_r(void)
{
	cpush(dpop());
}

void primitive_from_r(void)
{
	dpush(cpop());
}

F_VECTOR* stack_to_vector(CELL bottom, CELL top)
{
	CELL depth = (top - bottom + CELLS) / CELLS;
	F_VECTOR* v = vector(depth);
	F_ARRAY* a = untag_array_fast(v->array);
	memcpy(a + 1,(void*)bottom,depth * CELLS);
	v->top = tag_fixnum(depth);
	return v;
}

void primitive_datastack(void)
{
	maybe_gc(0);
	dpush(tag_object(stack_to_vector(ds_bot,ds)));
}

void primitive_callstack(void)
{
	maybe_gc(0);
	dpush(tag_object(stack_to_vector(cs_bot,cs)));
}

/* Returns top of stack */
CELL vector_to_stack(F_VECTOR* vector, CELL bottom)
{
	CELL start = bottom;
	CELL len = untag_fixnum_fast(vector->top) * CELLS;
	memcpy((void*)start,untag_array_fast(vector->array) + 1,len);
	return start + len - CELLS;
}

void primitive_set_datastack(void)
{
	ds = vector_to_stack(untag_vector(dpop()),ds_bot);
}

void primitive_set_callstack(void)
{
	cs = vector_to_stack(untag_vector(dpop()),cs_bot);
}
