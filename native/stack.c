#include "factor.h"

void reset_datastack(void)
{
	env.ds = env.ds_bot;
	env.dt = empty;
}

void reset_callstack(void)
{
	env.cs = env.cs_bot;
	cpush(empty);
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
	check_non_empty(env.dt);
	env.dt = dpop();
}

void primitive_dup(void)
{
	check_non_empty(env.dt);
	dpush(env.dt);
}

void primitive_swap(void)
{
	CELL top, next;
	check_non_empty(env.dt);
	check_non_empty(dpeek());
	top = env.dt;
	next = dpop();
	dpush(top);
	env.dt = next;
}

void primitive_over(void)
{
	CELL under = dpeek();
	check_non_empty(env.dt);
	check_non_empty(under);
	dpush(env.dt);
	env.dt = under;
}

void primitive_pick(void)
{
	CELL under = dpeek();
	CELL under_under = get(env.ds - CELLS * 2);
	check_non_empty(env.dt);
	check_non_empty(under);
	check_non_empty(under_under);
	dpush(env.dt);
	env.dt = under_under;
}

void primitive_nip(void)
{
	check_non_empty(dpeek());
	dpop();
}

void primitive_tuck(void)
{
	CELL under = dpeek();
	check_non_empty(env.dt);
	check_non_empty(under);
	dpop();
	dpush(env.dt);
	dpush(under);
}

void primitive_rot(void)
{
	CELL y, z;
	/* z y env.dt --> y env.dt z <top> */
	check_non_empty(env.dt);
	y = dpeek();
	check_non_empty(y);
	z = get(env.ds - CELLS * 2);
	check_non_empty(z);
	put(env.ds - CELLS * 2,y);
	put(env.ds - CELLS,env.dt);
	env.dt = z;
}

void primitive_to_r(void)
{
	check_non_empty(env.dt);
	cpush(env.dt);
	env.dt = dpop();
}

void primitive_from_r(void)
{
	check_non_empty(cpeek());
	dpush(env.dt);
	env.dt = cpop();
}

VECTOR* stack_to_vector(CELL bottom, CELL top)
{
	CELL depth = (top - bottom) / CELLS - 1;
	VECTOR* v = vector(depth);
	ARRAY* a = v->array;
	memcpy(a + 1,(char*)bottom + CELLS,depth * CELLS);
	v->top = depth;
	return v;
}

void primitive_datastack(void)
{
	dpush(env.dt);
	env.dt = tag_object(stack_to_vector(env.ds_bot,env.ds));
}

void primitive_callstack(void)
{
	dpush(env.dt);
	env.dt = tag_object(stack_to_vector(env.cs_bot,env.cs));
}

/* Returns top of stack */
CELL vector_to_stack(VECTOR* vector, CELL bottom)
{
	CELL start = bottom + CELLS;
	CELL len = vector->top * CELLS;
	memcpy((void*)start,vector->array + 1,len);
	return start + len;
}

void primitive_set_datastack(void)
{
	env.ds = vector_to_stack(untag_vector(env.dt),env.ds_bot);
	env.dt = dpop();
}

void primitive_set_callstack(void)
{
	env.cs = vector_to_stack(untag_vector(env.dt),env.cs_bot);
	env.dt = dpop();
}
