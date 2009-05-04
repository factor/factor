#include "master.hpp"

namespace factor
{

static void check_frame(stack_frame *frame)
{
#ifdef FACTOR_DEBUG
	check_code_pointer((cell)frame->xt);
	assert(frame->size != 0);
#endif
}

void iterate_callstack(cell top, cell bottom, CALLSTACK_ITER iterator)
{
	stack_frame *frame = (stack_frame *)bottom - 1;

	while((cell)frame >= top)
	{
		iterator(frame);
		frame = frame_successor(frame);
	}
}

void iterate_callstack_object(callstack *stack, CALLSTACK_ITER iterator)
{
	cell top = (cell)FIRST_STACK_FRAME(stack);
	cell bottom = top + untag_fixnum(stack->length);

	iterate_callstack(top,bottom,iterator);
}

callstack *allot_callstack(cell size)
{
	callstack *stack = allot<callstack>(callstack_size(size));
	stack->length = tag_fixnum(size);
	return stack;
}

stack_frame *fix_callstack_top(stack_frame *top, stack_frame *bottom)
{
	stack_frame *frame = bottom - 1;

	while(frame >= top)
		frame = frame_successor(frame);

	return frame + 1;
}

/* We ignore the topmost frame, the one calling 'callstack',
so that set-callstack doesn't get stuck in an infinite loop.

This means that if 'callstack' is called in tail position, we
will have popped a necessary frame... however this word is only
called by continuation implementation, and user code shouldn't
be calling it at all, so we leave it as it is for now. */
stack_frame *capture_start(void)
{
	stack_frame *frame = stack_chain->callstack_bottom - 1;
	while(frame >= stack_chain->callstack_top
		&& frame_successor(frame) >= stack_chain->callstack_top)
	{
		frame = frame_successor(frame);
	}
	return frame + 1;
}

PRIMITIVE(callstack)
{
	stack_frame *top = capture_start();
	stack_frame *bottom = stack_chain->callstack_bottom;

	fixnum size = (cell)bottom - (cell)top;
	if(size < 0)
		size = 0;

	callstack *stack = allot_callstack(size);
	memcpy(FIRST_STACK_FRAME(stack),top,size);
	dpush(tag<callstack>(stack));
}

PRIMITIVE(set_callstack)
{
	callstack *stack = untag_check<callstack>(dpop());

	set_callstack(stack_chain->callstack_bottom,
		FIRST_STACK_FRAME(stack),
		untag_fixnum(stack->length),
		memcpy);

	/* We cannot return here ... */
	critical_error("Bug in set_callstack()",0);
}

code_block *frame_code(stack_frame *frame)
{
	check_frame(frame);
	return (code_block *)frame->xt - 1;
}

cell frame_type(stack_frame *frame)
{
	return frame_code(frame)->block.type;
}

cell frame_executing(stack_frame *frame)
{
	code_block *compiled = frame_code(frame);
	if(compiled->literals == F || !stack_traces_p())
		return F;
	else
	{
		array *literals = untag<array>(compiled->literals);
		return array_nth(literals,0);
	}
}

stack_frame *frame_successor(stack_frame *frame)
{
	check_frame(frame);
	return (stack_frame *)((cell)frame - frame->size);
}

cell frame_scan(stack_frame *frame)
{
	if(frame_type(frame) == QUOTATION_TYPE)
	{
		cell quot = frame_executing(frame);
		if(quot == F)
			return F;
		else
		{
			char *return_addr = (char *)FRAME_RETURN_ADDRESS(frame);
			char *quot_xt = (char *)(frame_code(frame) + 1);

			return tag_fixnum(quot_code_offset_to_scan(
				quot,(cell)(return_addr - quot_xt)));
		}
	}
	else
		return F;
}

/* C doesn't have closures... */
static cell frame_count;

void count_stack_frame(stack_frame *frame)
{
	frame_count += 2; 
}

static cell frame_index;
static array *frames;

void stack_frame_to_array(stack_frame *frame)
{
	set_array_nth(frames,frame_index++,frame_executing(frame));
	set_array_nth(frames,frame_index++,frame_scan(frame));
}

PRIMITIVE(callstack_to_array)
{
	gc_root<callstack> callstack(dpop());

	frame_count = 0;
	iterate_callstack_object(callstack.untagged(),count_stack_frame);

	frames = allot_array_internal<array>(frame_count);

	frame_index = 0;
	iterate_callstack_object(callstack.untagged(),stack_frame_to_array);

	dpush(tag<array>(frames));
}

stack_frame *innermost_stack_frame(callstack *callstack)
{
	stack_frame *top = FIRST_STACK_FRAME(callstack);
	cell bottom = (cell)top + untag_fixnum(callstack->length);

	stack_frame *frame = (stack_frame *)bottom - 1;

	while(frame >= top && frame_successor(frame) >= top)
		frame = frame_successor(frame);

	return frame;
}

stack_frame *innermost_stack_frame_quot(callstack *callstack)
{
	stack_frame *inner = innermost_stack_frame(callstack);
	tagged<quotation>(frame_executing(inner)).untag_check();
	return inner;
}

/* Some primitives implementing a limited form of callstack mutation.
Used by the single stepper. */
PRIMITIVE(innermost_stack_frame_quot)
{
	dpush(frame_executing(innermost_stack_frame_quot(untag_check<callstack>(dpop()))));
}

PRIMITIVE(innermost_stack_frame_scan)
{
	dpush(frame_scan(innermost_stack_frame_quot(untag_check<callstack>(dpop()))));
}

PRIMITIVE(set_innermost_stack_frame_quot)
{
	gc_root<callstack> callstack(dpop());
	gc_root<quotation> quot(dpop());

	callstack.untag_check();
	quot.untag_check();

	jit_compile(quot.value(),true);

	stack_frame *inner = innermost_stack_frame_quot(callstack.untagged());
	cell offset = (char *)FRAME_RETURN_ADDRESS(inner) - (char *)inner->xt;
	inner->xt = quot->xt;
	FRAME_RETURN_ADDRESS(inner) = (char *)quot->xt + offset;
}

/* called before entry into Factor code. */
VM_ASM_API void save_callstack_bottom(stack_frame *callstack_bottom)
{
	stack_chain->callstack_bottom = callstack_bottom;
}

}
