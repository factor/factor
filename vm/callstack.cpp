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
stack_frame *capture_start()
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
	memcpy(stack->top(),top,size);
	dpush(tag<callstack>(stack));
}

PRIMITIVE(set_callstack)
{
	callstack *stack = untag_check<callstack>(dpop());

	set_callstack(stack_chain->callstack_bottom,
		stack->top(),
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
	return frame_code(frame)->type;
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

namespace
{

struct stack_frame_counter {
	cell count;
	stack_frame_counter() : count(0) {}
	void operator()(stack_frame *frame) { count += 2; }
};

struct stack_frame_accumulator {
	cell index;
	array *frames;
	stack_frame_accumulator(cell count) : index(0), frames(allot_array_internal<array>(count)) {}
	void operator()(stack_frame *frame)
	{
		set_array_nth(frames,index++,frame_executing(frame));
		set_array_nth(frames,index++,frame_scan(frame));
	}
};

}

PRIMITIVE(callstack_to_array)
{
	gc_root<callstack> callstack(dpop());

	stack_frame_counter counter;
	iterate_callstack_object(callstack.untagged(),counter);

	stack_frame_accumulator accum(counter.count);
	iterate_callstack_object(callstack.untagged(),accum);

	dpush(tag<array>(accum.frames));
}

stack_frame *innermost_stack_frame(callstack *stack)
{
	stack_frame *top = stack->top();
	stack_frame *bottom = stack->bottom();
	stack_frame *frame = bottom - 1;

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
PRIMITIVE(innermost_stack_frame_executing)
{
	dpush(frame_executing(innermost_stack_frame(untag_check<callstack>(dpop()))));
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
