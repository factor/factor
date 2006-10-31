#include "factor.h"

void reset_datastack(void)
{
	ds = ds_bot - CELLS;
}

void reset_retainstack(void)
{
	rs = rs_bot - CELLS;
}

void reset_callstack(void)
{
	cs = cs_bot - CELLS;
}

void fix_stacks(void)
{
	if(STACK_UNDERFLOW(ds,stack_chain->data_region))
		reset_datastack();
	if(STACK_OVERFLOW(ds,stack_chain->data_region))
		reset_datastack();
	if(STACK_UNDERFLOW(rs,stack_chain->retain_region))
		reset_retainstack();
	if(STACK_OVERFLOW(rs,stack_chain->retain_region))
		reset_retainstack();
	if(STACK_UNDERFLOW(cs,stack_chain->call_region))
		reset_callstack();
	if(STACK_OVERFLOW(cs,stack_chain->call_region))
		reset_callstack();
}

/* called before entry into foreign C code. Note that ds, rs and cs might
be stored in registers, so callbacks must save and restore the correct values */
void save_stacks(void)
{
	stack_chain->data = ds;
	stack_chain->retain = rs;
	stack_chain->call = cs;
}

/* called on entry into a compiled callback */
void nest_stacks(void)
{
	STACKS *new_stacks = safe_malloc(sizeof(STACKS));
	
	/* note that these register values are not necessarily valid stack
	pointers. they are merely saved non-volatile registers, and are
	restored in unnest_stacks(). consider this scenario:
	- factor code calls C function
	- C function saves ds/cs registers (since they're non-volatile)
	- C function clobbers them
	- C function calls Factor callback
	- Factor callback returns
	- C function restores registers
	- C function returns to Factor code */
	new_stacks->data_save = ds;
	new_stacks->retain_save = rs;
	new_stacks->call_save = cs;
	new_stacks->cards_offset = cards_offset;

	new_stacks->callframe = callframe;
	new_stacks->callframe_scan = callframe_scan;
	new_stacks->callframe_end = callframe_end;
	new_stacks->catch_save = userenv[CATCHSTACK_ENV];

	new_stacks->data_region = alloc_bounded_block(ds_size);
	new_stacks->retain_region = alloc_bounded_block(rs_size);
	new_stacks->call_region = alloc_bounded_block(cs_size);

	new_stacks->next = stack_chain;
	stack_chain = new_stacks;

	callframe = F;
	callframe_scan = callframe_end = 0;
	reset_datastack();
	reset_retainstack();
	reset_callstack();
	update_cards_offset();
}

/* called when leaving a compiled callback */
void unnest_stacks(void)
{
	STACKS *old_stacks = stack_chain;

	dealloc_bounded_block(stack_chain->data_region);
	dealloc_bounded_block(stack_chain->retain_region);
	dealloc_bounded_block(stack_chain->call_region);

	ds = old_stacks->data_save;
	rs = old_stacks->retain_save;
	cs = old_stacks->call_save;
	cards_offset = old_stacks->cards_offset;

	callframe = old_stacks->callframe;
	callframe_scan = old_stacks->callframe_scan;
	callframe_end = old_stacks->callframe_end;
	userenv[CATCHSTACK_ENV] = old_stacks->catch_save;

	stack_chain = old_stacks->next;

	free(old_stacks);
}

/* called on startup */
void init_stacks(CELL ds_size_, CELL rs_size_, CELL cs_size_)
{
	ds_size = ds_size_;
	rs_size = rs_size_;
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
	rpush(dpop());
}

void primitive_from_r(void)
{
	dpush(rpop());
}

void stack_to_vector(CELL bottom, CELL top)
{
	CELL depth = (top - bottom + CELLS) / CELLS;
	F_ARRAY *a = allot_array_internal(ARRAY_TYPE,depth);
	memcpy(a + 1,(void*)bottom,depth * CELLS);
	dpush(tag_object(a));
	primitive_array_to_vector();
}

void primitive_datastack(void)
{
	stack_to_vector(ds_bot,ds);
}

void primitive_retainstack(void)
{
	stack_to_vector(rs_bot,rs);
}

void primitive_callstack(void)
{
	CELL depth = (cs - cs_bot + CELLS) / CELLS - 3;
	F_ARRAY *a = allot_array_internal(ARRAY_TYPE,depth);
	CELL i;
	CELL ptr = cs_bot;
	
	for(i = 0; i < depth; i += 3, ptr += 3 * CELLS)
	{
		CELL quot = get(ptr);
		CELL untagged = UNTAG(quot);
		CELL position = UNAREF(untagged,get(ptr + CELLS));
		CELL end = UNAREF(untagged,get(ptr + CELLS * 2));
		put(AREF(a,i),quot);
		put(AREF(a,i + 1),tag_fixnum(position));
		put(AREF(a,i + 2),tag_fixnum(end));
	}

	dpush(tag_object(a));
	primitive_array_to_vector();
}

/* returns pointer to top of stack */
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

void primitive_set_retainstack(void)
{
	rs = vector_to_stack(untag_vector(dpop()),rs_bot);
}

void primitive_set_callstack(void)
{
	F_VECTOR *v = untag_vector(dpop());
	F_ARRAY *a = untag_array_fast(v->array);

	CELL depth = untag_fixnum_fast(v->top);
	depth -= (depth % 3);

	CELL i, ptr;
	for(i = 0, ptr = cs_bot; i < depth; i += 3, ptr += 3 * CELLS)
	{
		CELL quot = get(AREF(a,i));
		type_check(QUOTATION_TYPE,quot);

		F_ARRAY *untagged = (F_ARRAY*)UNTAG(quot);
		CELL length = array_capacity(untagged);

		F_FIXNUM position = to_fixnum(get(AREF(a,i + 1)));
		F_FIXNUM end = to_fixnum(get(AREF(a,i + 2)));

		if(end < 0) end = 0;
		if(end > length) end = length;
		if(position < 0) position = 0;
		if(position > end) position = end;

		put(ptr,quot);
		put(ptr + CELLS,AREF(untagged,position));
		put(ptr + CELLS * 2,AREF(untagged,end));
	}

	cs = cs_bot + depth * CELLS - CELLS;
}
