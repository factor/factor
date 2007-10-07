#include "master.h"

/* called before entry into Factor code. */
F_FASTCALL void save_callstack_bottom(F_STACK_FRAME *callstack_bottom)
{
	stack_chain->callstack_bottom = callstack_bottom;
}

F_FASTCALL __attribute__((noinline)) void save_callstack_top(F_STACK_FRAME *callstack_top)
{
	stack_chain->callstack_top = callstack_top;
}

void iterate_callstack(CELL top, CELL bottom, CALLSTACK_ITER iterator)
{
	F_STACK_FRAME *frame = (F_STACK_FRAME *)bottom - 1;

	while((CELL)frame >= top)
	{
		F_STACK_FRAME *next = frame_successor(frame);
		iterator(frame);
		frame = next;
	}
}

void iterate_callstack_object(F_CALLSTACK *stack, CALLSTACK_ITER iterator)
{
	CELL top = (CELL)FIRST_STACK_FRAME(stack);
	CELL bottom = top + untag_fixnum_fast(stack->length);

	iterate_callstack(top,bottom,iterator);
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
	F_STACK_FRAME *frame = stack_chain->callstack_bottom - 1;
	while(frame >= stack_chain->callstack_top
		&& frame_successor(frame) >= stack_chain->callstack_top)
	{
		frame = frame_successor(frame);
	}
	return frame + 1;
}

DEFINE_PRIMITIVE(callstack)
{
	F_STACK_FRAME *top = capture_start();
	F_STACK_FRAME *bottom = stack_chain->callstack_bottom;

	F_FIXNUM size = (CELL)bottom - (CELL)top;
	if(size < 0)
		size = 0;

	F_CALLSTACK *callstack = allot_callstack(size);
	memcpy(FIRST_STACK_FRAME(callstack),top,size);
	dpush(tag_object(callstack));
}

DEFINE_PRIMITIVE(set_callstack)
{
	F_CALLSTACK *stack = untag_callstack(dpop());

	set_callstack(stack_chain->callstack_bottom,
		FIRST_STACK_FRAME(stack),
		untag_fixnum_fast(stack->length),
		memcpy);

	/* We cannot return here ... */
	critical_error("Bug in set_callstack()",0);
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

F_STACK_FRAME *frame_successor(F_STACK_FRAME *frame)
{
	return (F_STACK_FRAME *)((CELL)frame - frame->size);
}

CELL frame_scan(F_STACK_FRAME *frame)
{
	if(frame_type(frame) == QUOTATION_TYPE)
		return tag_fixnum(UNAREF(UNTAG(frame->array),frame->scan));
	else
		return F;
}

/* C doesn't have closures... */
static CELL frame_count;

void count_stack_frame(F_STACK_FRAME *frame)
{
	frame_count += 2; 
}

static CELL frame_index;
static F_ARRAY *array;

void stack_frame_to_array(F_STACK_FRAME *frame)
{
	set_array_nth(array,frame_index++,frame_executing(frame));
	set_array_nth(array,frame_index++,frame_scan(frame));
}

DEFINE_PRIMITIVE(callstack_to_array)
{
	F_CALLSTACK *stack = untag_callstack(dpop());

	frame_count = 0;
	iterate_callstack_object(stack,count_stack_frame);

	REGISTER_UNTAGGED(stack);
	array = allot_array_internal(ARRAY_TYPE,frame_count);
	UNREGISTER_UNTAGGED(stack);

	frame_index = 0;
	iterate_callstack_object(stack,stack_frame_to_array);

	dpush(tag_object(array));
}

F_STACK_FRAME *innermost_stack_frame(F_CALLSTACK *callstack)
{
	F_STACK_FRAME *top = FIRST_STACK_FRAME(callstack);
	CELL bottom = (CELL)top + untag_fixnum_fast(callstack->length);

	F_STACK_FRAME *frame = (F_STACK_FRAME *)bottom - 1;

	while(frame >= top && frame_successor(frame) >= top)
		frame = frame_successor(frame);

	return frame;
}

/* Some primitives implementing a limited form of callstack mutation.
Used by the single stepper. */
DEFINE_PRIMITIVE(innermost_stack_frame_quot)
{
	F_STACK_FRAME *inner = innermost_stack_frame(
		untag_callstack(dpop()));
	type_check(QUOTATION_TYPE,frame_executing(inner));

	dpush(frame_executing(inner));
}

DEFINE_PRIMITIVE(innermost_stack_frame_scan)
{
	F_STACK_FRAME *inner = innermost_stack_frame(
		untag_callstack(dpop()));
	type_check(QUOTATION_TYPE,frame_executing(inner));

	dpush(frame_scan(inner));
}

DEFINE_PRIMITIVE(set_innermost_stack_frame_quot)
{
	F_CALLSTACK *callstack = untag_callstack(dpop());
	F_QUOTATION *quot = untag_quotation(dpop());

	REGISTER_UNTAGGED(callstack);
	REGISTER_UNTAGGED(quot);

	if(quot->compiled == F)
		jit_compile(quot);

	UNREGISTER_UNTAGGED(quot);
	UNREGISTER_UNTAGGED(callstack);

	F_STACK_FRAME *inner = innermost_stack_frame(callstack);
	type_check(QUOTATION_TYPE,frame_executing(inner));

	CELL scan = inner->scan - inner->array;
	CELL offset = FRAME_RETURN_ADDRESS(inner) - inner->xt;

	inner->array = quot->array;
	inner->scan = quot->array + scan;

	inner->xt = quot->xt;

	FRAME_RETURN_ADDRESS(inner) = quot->xt + offset;
}
