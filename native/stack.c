#include "factor.h"

void reset_datastack(void)
{
	env.ds = env.ds_bot;
}

void reset_callstack(void)
{
	env.cs = env.cs_bot;
}

void init_stacks(void)
{
	env.ds_bot = (CELL)alloc_guarded(STACK_SIZE);
	reset_datastack();
	env.cs_bot = (CELL)alloc_guarded(STACK_SIZE);
	reset_callstack();
	env.cf = env.boot;
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
	CELL next = get(env.ds - CELLS * 2);
	put(env.ds - CELLS,next);
	put(env.ds - CELLS * 2,top);
}

void primitive_over(void)
{
	dpush(get(env.ds - CELLS * 2));
}

void primitive_pick(void)
{
	dpush(get(env.ds - CELLS * 3));
}

void primitive_nip(void)
{
	CELL top = dpop();
	put(env.ds - CELLS,top);
}

void primitive_tuck(void)
{
	CELL top = dpeek();
	CELL next = get(env.ds - CELLS * 2);
	put(env.ds - CELLS * 2,top);
	put(env.ds - CELLS,next);
	dpush(top);
}

void primitive_rot(void)
{
	CELL top = dpeek();
	CELL next = get(env.ds - CELLS * 2);
	CELL next_next = get(env.ds - CELLS * 3);
	put(env.ds - CELLS * 3,next);
	put(env.ds - CELLS * 2,top);
	put(env.ds - CELLS,next_next);
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
	dpush(tag_object(stack_to_vector(env.ds_bot,env.ds)));
}

void primitive_callstack(void)
{
	dpush(tag_object(stack_to_vector(env.cs_bot,env.cs)));
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
	env.ds = vector_to_stack(untag_vector(dpop()),env.ds_bot);
}

void primitive_set_callstack(void)
{
	env.cs = vector_to_stack(untag_vector(dpop()),env.cs_bot);
}
