#include "factor.h"

void reset_datastack(void)
{
	ds = ds_bot;
}

void reset_callstack(void)
{
	cs = cs_bot;
}

void init_stacks(void)
{
	ds_bot = (CELL)alloc_guarded(STACK_SIZE);
	reset_datastack();
	cs_bot = (CELL)alloc_guarded(STACK_SIZE);
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
	CELL next = get(ds - CELLS * 2);
	put(ds - CELLS,next);
	put(ds - CELLS * 2,top);
}

void primitive_over(void)
{
	dpush(get(ds - CELLS * 2));
}

void primitive_pick(void)
{
	dpush(get(ds - CELLS * 3));
}

void primitive_nip(void)
{
	CELL top = dpop();
	put(ds - CELLS,top);
}

void primitive_tuck(void)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS * 2);
	put(ds - CELLS * 2,top);
	put(ds - CELLS,next);
	dpush(top);
}

void primitive_rot(void)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS * 2);
	CELL next_next = get(ds - CELLS * 3);
	put(ds - CELLS * 3,next);
	put(ds - CELLS * 2,top);
	put(ds - CELLS,next_next);
}

void primitive_to_r(void)
{
	cpush(dpop());
}

void primitive_from_r(void)
{
	dpush(cpop());
}

VECTOR* stack_to_vector(CELL bottom, CELL top)
{
	CELL depth = (top - bottom) / CELLS;
	VECTOR* v = vector(depth);
	ARRAY* a = v->array;
	memcpy(a + 1,(void*)bottom,depth * CELLS);
	v->top = depth;
	return v;
}

void primitive_datastack(void)
{
	dpush(tag_object(stack_to_vector(ds_bot,ds)));
}

void primitive_callstack(void)
{
	/* we don't want gc word to end up on callstack. */
	gc_protect = true;
	dpush(tag_object(stack_to_vector(cs_bot,cs)));
	gc_protect = false;
}

/* Returns top of stack */
CELL vector_to_stack(VECTOR* vector, CELL bottom)
{
	CELL start = bottom;
	CELL len = vector->top * CELLS;
	memcpy((void*)start,vector->array + 1,len);
	return start + len;
}

void primitive_set_datastack(void)
{
	ds = vector_to_stack(untag_vector(dpop()),ds_bot);
}

void primitive_set_callstack(void)
{
	cs = vector_to_stack(untag_vector(dpop()),cs_bot);
}
