#include "master.h"

void reset_datastack(void)
{
	ds = ds_bot - CELLS;
}

void reset_retainstack(void)
{
	rs = rs_bot - CELLS;
}

#define RESERVED (64 * CELLS)

void fix_stacks(void)
{
	if(ds + CELLS < ds_bot || ds + RESERVED >= ds_top) reset_datastack();
	if(rs + CELLS < rs_bot || rs + RESERVED >= rs_top) reset_retainstack();
}

/* called before entry into Factor code. */
void save_callstack_bottom(F_STACK_FRAME *callstack_bottom)
{
	stack_chain->callstack_bottom = callstack_bottom;
}

/* called before entry into foreign C code. Note that ds and rs might
be stored in registers, so callbacks must save and restore the correct values */
void save_stacks(void)
{
	stack_chain->datastack = ds;
	stack_chain->retainstack = rs;
}

/* called on entry into a compiled callback */
void nest_stacks(void)
{
	F_CONTEXT *new_stacks = safe_malloc(sizeof(F_CONTEXT));

	new_stacks->callstack_bottom = (F_STACK_FRAME *)-1;
	new_stacks->callstack_top = (F_STACK_FRAME *)-1;

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
	new_stacks->datastack_save = ds;
	new_stacks->retainstack_save = rs;

	/* save per-callback userenv */
	new_stacks->current_callback_save = userenv[CURRENT_CALLBACK_ENV];
	new_stacks->catchstack_save = userenv[CATCHSTACK_ENV];

	new_stacks->datastack_region = alloc_segment(ds_size);
	new_stacks->retainstack_region = alloc_segment(rs_size);

	new_stacks->extra_roots = extra_roots;

	new_stacks->next = stack_chain;
	stack_chain = new_stacks;

	reset_datastack();
	reset_retainstack();
}

/* called when leaving a compiled callback */
void unnest_stacks(void)
{
	dealloc_segment(stack_chain->datastack_region);
	dealloc_segment(stack_chain->retainstack_region);

	ds = stack_chain->datastack_save;
	rs = stack_chain->retainstack_save;

	/* restore per-callback userenv */
	userenv[CURRENT_CALLBACK_ENV] = stack_chain->current_callback_save;
	userenv[CATCHSTACK_ENV] = stack_chain->catchstack_save;

	extra_roots = stack_chain->extra_roots;

	F_CONTEXT *old_stacks = stack_chain;
	stack_chain = old_stacks->next;
	free(old_stacks);
}

/* called on startup */
void init_stacks(CELL ds_size_, CELL rs_size_)
{
	ds_size = ds_size_;
	rs_size = rs_size_;
	stack_chain = NULL;
}

void iterate_callstack(CELL top, CELL bottom, CELL base, CALLSTACK_ITER iterator)
{
	CELL delta = (bottom - base);

#ifdef CALLSTACK_UP_P
	F_STACK_FRAME *frame = (F_STACK_FRAME *)bottom - 1;
	#define ITERATING_P (CELL)frame >= top
#else
	F_STACK_FRAME *frame = (F_STACK_FRAME *)top;
	#define ITERATING_P (CELL)frame < bottom
#endif

	while(ITERATING_P)
	{
		F_STACK_FRAME *next = (F_STACK_FRAME *)((CELL)FRAME_SUCCESSOR(frame) + delta);
		iterator(frame);
		frame = next;
	}
}

void iterate_callstack_object(F_CALLSTACK *stack, CALLSTACK_ITER iterator)
{
	CELL top = (CELL)(stack + 1);
	CELL bottom = top + untag_fixnum_fast(stack->length);
	CELL base = stack->bottom;

	iterate_callstack(top,bottom,base,iterator);
}

DEFINE_PRIMITIVE(drop)
{
	dpop();
}

DEFINE_PRIMITIVE(2drop)
{
	ds -= 2 * CELLS;
}

DEFINE_PRIMITIVE(3drop)
{
	ds -= 3 * CELLS;
}

DEFINE_PRIMITIVE(dup)
{
	dpush(dpeek());
}

DEFINE_PRIMITIVE(2dup)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS);
	ds += CELLS * 2;
	put(ds - CELLS,next);
	put(ds,top);
}

DEFINE_PRIMITIVE(3dup)
{
	CELL c1 = dpeek();
	CELL c2 = get(ds - CELLS);
	CELL c3 = get(ds - CELLS * 2);
	ds += CELLS * 3;
	put (ds,c1);
	put (ds - CELLS,c2);
	put (ds - CELLS * 2,c3);
}

DEFINE_PRIMITIVE(rot)
{
	CELL c1 = dpeek();
	CELL c2 = get(ds - CELLS);
	CELL c3 = get(ds - CELLS * 2);
	put(ds,c3);
	put(ds - CELLS,c1);
	put(ds - CELLS * 2,c2);
}

DEFINE_PRIMITIVE(_rot)
{
	CELL c1 = dpeek();
	CELL c2 = get(ds - CELLS);
	CELL c3 = get(ds - CELLS * 2);
	put(ds,c2);
	put(ds - CELLS,c3);
	put(ds - CELLS * 2,c1);
}

DEFINE_PRIMITIVE(dupd)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS);
	put(ds,next);
	put(ds - CELLS,next);
	dpush(top);
}

DEFINE_PRIMITIVE(swapd)
{
	CELL top = get(ds - CELLS);
	CELL next = get(ds - CELLS * 2);
	put(ds - CELLS,next);
	put(ds - CELLS * 2,top);
}

DEFINE_PRIMITIVE(nip)
{
	CELL top = dpop();
	drepl(top);
}

DEFINE_PRIMITIVE(2nip)
{
	CELL top = dpeek();
	ds -= CELLS * 2;
	drepl(top);
}

DEFINE_PRIMITIVE(tuck)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS);
	put(ds,next);
	put(ds - CELLS,top);
	dpush(top);
}

DEFINE_PRIMITIVE(over)
{
	dpush(get(ds - CELLS));
}

DEFINE_PRIMITIVE(pick)
{
	dpush(get(ds - CELLS * 2));
}

DEFINE_PRIMITIVE(swap)
{
	CELL top = dpeek();
	CELL next = get(ds - CELLS);
	put(ds,next);
	put(ds - CELLS,top);
}

DEFINE_PRIMITIVE(to_r)
{
	rpush(dpop());
}

DEFINE_PRIMITIVE(from_r)
{
	dpush(rpop());
}

void stack_to_array(CELL bottom, CELL top)
{
	F_FIXNUM depth = (F_FIXNUM)(top - bottom + CELLS);

	if(depth < 0) critical_error("depth < 0",0);

	F_ARRAY *a = allot_array_internal(ARRAY_TYPE,depth / CELLS);
	memcpy(a + 1,(void*)bottom,depth);
	dpush(tag_object(a));
}

DEFINE_PRIMITIVE(datastack)
{
	stack_to_array(ds_bot,ds);
}

DEFINE_PRIMITIVE(retainstack)
{
	stack_to_array(rs_bot,rs);
}

/* returns pointer to top of stack */
CELL array_to_stack(F_ARRAY *array, CELL bottom)
{
	CELL depth = array_capacity(array) * CELLS;
	memcpy((void*)bottom,array + 1,depth);
	return bottom + depth - CELLS;
}

DEFINE_PRIMITIVE(set_datastack)
{
	ds = array_to_stack(untag_array(dpop()),ds_bot);
}

DEFINE_PRIMITIVE(set_retainstack)
{
	rs = array_to_stack(untag_array(dpop()),rs_bot);
}

F_CALLSTACK *allot_callstack(CELL size)
{
	F_CALLSTACK *callstack = allot_object(
		CALLSTACK_TYPE,
		callstack_size(size));
	callstack->length = tag_fixnum(size);
	return callstack;
}

/* We ignore the topmost frame, the one calling 'callstack',
so that set-callstack doesn't get stuck in an infinite loop.

This means that if 'callstack' is called in tail position, we
will have popped a necessary frame... however this word is only
called by continuation implementation, and user code shouldn't
be calling it at all, so we leave it as it is for now. */
F_STACK_FRAME *capture_start(void)
{
#ifdef CALLSTACK_UP_P
	F_STACK_FRAME *frame = stack_chain->callstack_bottom - 1;
	while(frame >= stack_chain->callstack_top
		&& FRAME_SUCCESSOR(frame) >= stack_chain->callstack_top)
	{
		frame = FRAME_SUCCESSOR(frame);
	}
	return frame + 1;
#else
	return FRAME_SUCCESSOR(stack_chain->callstack_top);
#endif
}

DEFINE_PRIMITIVE(callstack)
{
	F_STACK_FRAME *top = capture_start();
	F_STACK_FRAME *bottom = stack_chain->callstack_bottom;

	F_FIXNUM size = (CELL)bottom - (CELL)top;
	if(size < 0)
		size = 0;

	F_CALLSTACK *callstack = allot_callstack(size);
	callstack->bottom = (CELL)bottom;
	memcpy(FIRST_STACK_FRAME(callstack),top,size);
	dpush(tag_object(callstack));
}

/* If a callstack object was captured at a different base stack height than
we have now, we have to patch up the back-chain pointers. */
static F_FIXNUM delta;

void adjust_stack_frame(F_STACK_FRAME *frame)
{
	FRAME_SUCCESSOR(frame) = (F_STACK_FRAME *)((CELL)FRAME_SUCCESSOR(frame) + delta);
}

void adjust_callstack(F_CALLSTACK *stack, CELL bottom)
{
	delta = (bottom - stack->bottom);
	iterate_callstack_object(stack,adjust_stack_frame);
	stack->bottom = bottom;
}

DEFINE_PRIMITIVE(set_callstack)
{
	F_CALLSTACK *stack = untag_callstack(dpop());

	CELL bottom = (CELL)stack_chain->callstack_bottom;

	if(stack->bottom != bottom)
		adjust_callstack(stack,bottom);

	set_callstack(stack_chain->callstack_bottom,
		FIRST_STACK_FRAME(stack),
		untag_fixnum_fast(stack->length),
		memcpy);

	/* We cannot return here ... */
	critical_error("Bug in set_callstack()",0);
}

/* C doesn't have closures... */
static CELL frame_count;
static CELL frame_index;
static F_ARRAY *array;

void count_stack_frame(F_STACK_FRAME *frame) {
	frame_count += 2; 
}

CELL frame_type(F_STACK_FRAME *frame)
{
	return xt_to_compiled(frame->xt)->type;
}

CELL frame_executing(F_STACK_FRAME *frame)
{
	F_COMPILED *compiled = xt_to_compiled(frame->xt);
	CELL code_start = (CELL)(compiled + 1);
	CELL literal_start = code_start
		+ compiled->code_length
		+ compiled->reloc_length;

	return get(literal_start);
}

void stack_frame_to_array(F_STACK_FRAME *frame)
{
	CELL offset;

	if(frame_type(frame) == QUOTATION_TYPE)
		offset = tag_fixnum(UNAREF(UNTAG(frame->array),frame->scan));
	else
		offset = F;

#ifdef CALLSTACK_UP_P
	#define I(n) (n)
#else
	#define I(n) (array_capacity(array) - (n) - 1)
#endif

	set_array_nth(array,I(frame_index++),frame_executing(frame));
	set_array_nth(array,I(frame_index++),offset);
}

DEFINE_PRIMITIVE(callstack_to_array)
{
	F_CALLSTACK *stack = untag_callstack(dpop());

	frame_count = 0;
	iterate_callstack_object(stack,count_stack_frame);

	REGISTER_UNTAGGED(stack);
	array = allot_array_internal(ARRAY_TYPE,frame_count);
	UNREGISTER_UNTAGGED(stack);

	/* frame_count is equal to the total length now */

	frame_index = 0;
	iterate_callstack_object(stack,stack_frame_to_array);

	dpush(tag_object(array));
}

DEFINE_PRIMITIVE(array_to_callstack)
{
	F_ARRAY *array = untag_array(dpop());

	CELL count = array_capacity(array);

	if(count % 2 == 1)
	{
		/* malformed array? type checks below will catch it */
		count--;
	}

	REGISTER_UNTAGGED(array);
	F_CALLSTACK *callstack = allot_callstack(count / 2 * sizeof(F_STACK_FRAME));
	UNREGISTER_UNTAGGED(array);

	F_STACK_FRAME *next = NULL;
	F_STACK_FRAME *current = FIRST_STACK_FRAME(callstack);

	while(count > 0)
	{
		F_FIXNUM offset = to_fixnum(array_nth(array,--count));

		F_QUOTATION *quot = untag_quotation(array_nth(array,--count));

		current->array = quot->array;
		current->scan = AREF(UNTAG(quot->array),offset);
		current->xt = quot->xt;
		//current->return_address = quot_offset_to_pc(quot,offset);

		if(next) FRAME_SUCCESSOR(next) = current;

		next = current;
		current++;
	}

	if(next) FRAME_SUCCESSOR(next) = current;

	callstack->bottom = (CELL)current;

	dpush(tag_object(callstack));
}
