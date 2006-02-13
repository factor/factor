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
	if(STACK_UNDERFLOW(ds,stack_chain->ds_region))
		reset_datastack();
	else if(STACK_OVERFLOW(ds,stack_chain->ds_region))
		reset_datastack();
	else if(STACK_UNDERFLOW(cs,stack_chain->cs_region))
		reset_callstack();
	else if(STACK_OVERFLOW(cs,stack_chain->cs_region))
		reset_callstack();
}

/* called before entry into foreign C code. Note that ds and cs are stored
in registers, so callbacks must save and restore the correct values */
void save_stacks(void)
{
	/* we want to save the current callframe along with the call stack */
	call(F);

	stack_chain->ds = ds;
	stack_chain->cs = cs;
}

/* called on entry into a compiled callback */
void nest_stacks(void)
{
	STACKS *new_stacks = malloc(sizeof(STACKS));
	if(new_stacks == NULL)
		fatal_error("Cannot allocate saved stacks struct",0);
	
	new_stacks->ds_save = ds;
	new_stacks->cs_save = cs;
	new_stacks->ds_region = alloc_bounded_block(ds_size);
	new_stacks->cs_region = alloc_bounded_block(cs_size);
	new_stacks->next = stack_chain;
	stack_chain = new_stacks;
	reset_datastack();
	reset_callstack();
}

/* called when leaving a compiled callback */
void unnest_stacks(void)
{
	dealloc_bounded_block(stack_chain->ds_region);
	dealloc_bounded_block(stack_chain->cs_region);
	ds = stack_chain->ds_save;
	cs = stack_chain->cs_save;
	stack_chain = stack_chain->next;
}

void init_stacks(CELL ds_size_, CELL cs_size_)
{
	ds_size = ds_size_;
	cs_size = cs_size_;
	stack_chain = NULL;
	nest_stacks();
}

void primitive_drop(void)
{
	dpop();
}

void primitive_2drop(void)
{
	ds -= 2 * CELLS;
}

void primitive_3drop(void)
{
	ds -= 3 * CELLS;
}

void primitive_dup(void)
{
	dpush(dpeek());
}

void primitive_2dup(void)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS);
	ds += CELLS * 2;
	put(ds - CELLS,next);
	put(ds,top);
}

void primitive_3dup(void)
{
	CELL c1 = dpeek();
	CELL c2 = get(ds - CELLS);
	CELL c3 = get(ds - CELLS * 2);
	ds += CELLS * 3;
	put (ds,c1);
	put (ds - CELLS,c2);
	put (ds - CELLS * 2,c3);
}

void primitive_rot(void)
{
	CELL c1 = dpeek();
	CELL c2 = get(ds - CELLS);
	CELL c3 = get(ds - CELLS * 2);
	put(ds,c3);
	put(ds - CELLS,c1);
	put(ds - CELLS * 2,c2);
}

void primitive__rot(void)
{
	CELL c1 = dpeek();
	CELL c2 = get(ds - CELLS);
	CELL c3 = get(ds - CELLS * 2);
	put(ds,c2);
	put(ds - CELLS,c3);
	put(ds - CELLS * 2,c1);
}

void primitive_dupd(void)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS);
	put(ds,next);
	put(ds - CELLS,next);
	dpush(top);
}

void primitive_swapd(void)
{
	CELL top = get(ds - CELLS);
	CELL next = get(ds - CELLS * 2);
	put(ds - CELLS,next);
	put(ds - CELLS * 2,top);
}

void primitive_nip(void)
{
	CELL top = dpop();
	drepl(top);
}

void primitive_2nip(void)
{
	CELL top = dpeek();
	ds -= CELLS * 2;
	drepl(top);
}

void primitive_tuck(void)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS);
	put(ds,next);
	put(ds - CELLS,top);
	dpush(top);
}

void primitive_over(void)
{
	dpush(get(ds - CELLS));
}

void primitive_pick(void)
{
	dpush(get(ds - CELLS * 2));
}

void primitive_swap(void)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS);
	put(ds,next);
	put(ds - CELLS,top);
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
