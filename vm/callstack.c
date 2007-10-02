#include "master.h"

/* called before entry into Factor code. */
F_FASTCALL void save_callstack_bottom(F_STACK_FRAME *callstack_bottom)
{
	stack_chain->callstack_bottom = callstack_bottom;
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
		F_STACK_FRAME *next = REBASE_FRAME_SUCCESSOR(frame,delta);
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
	FRAME_SUCCESSOR(frame) = REBASE_FRAME_SUCCESSOR(frame,delta);
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
	set_array_nth(array,frame_index++,frame_executing(frame));
	set_array_nth(array,frame_index++,offset);
#else
	set_array_nth(array,frame_index--,offset);
	set_array_nth(array,frame_index--,frame_executing(frame));
#endif
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

#ifdef CALLSTACK_UP_P
	frame_index = 0;
#else
	frame_index = frame_count - 1;
#endif

	iterate_callstack_object(stack,stack_frame_to_array);

	dpush(tag_object(array));
}
