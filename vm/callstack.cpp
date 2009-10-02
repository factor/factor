#include "master.hpp"

namespace factor
{

void factor_vm::check_frame(stack_frame *frame)
{
#ifdef FACTOR_DEBUG
	check_code_pointer((cell)frame->xt);
	assert(frame->size != 0);
#endif
}

callstack *factor_vm::allot_callstack(cell size)
{
	callstack *stack = allot<callstack>(callstack_size(size));
	stack->length = tag_fixnum(size);
	return stack;
}

stack_frame *factor_vm::fix_callstack_top(stack_frame *top, stack_frame *bottom)
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
stack_frame *factor_vm::capture_start()
{
	stack_frame *frame = stack_chain->callstack_bottom - 1;
	while(frame >= stack_chain->callstack_top
		&& frame_successor(frame) >= stack_chain->callstack_top)
	{
		frame = frame_successor(frame);
	}
	return frame + 1;
}

void factor_vm::primitive_callstack()
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

void factor_vm::primitive_set_callstack()
{
	callstack *stack = untag_check<callstack>(dpop());

	set_callstack(stack_chain->callstack_bottom,
		stack->top(),
		untag_fixnum(stack->length),
		memcpy);

	/* We cannot return here ... */
	critical_error("Bug in set_callstack()",0);
}

code_block *factor_vm::frame_code(stack_frame *frame)
{
	check_frame(frame);
	return (code_block *)frame->xt - 1;
}

cell factor_vm::frame_type(stack_frame *frame)
{
	return frame_code(frame)->type;
}

cell factor_vm::frame_executing(stack_frame *frame)
{
	code_block *compiled = frame_code(frame);
	if(compiled->literals == F || !stack_traces_p())
		return F;
	else
	{
		array *literals = untag<array>(compiled->literals);
		cell executing = array_nth(literals,0);
		check_data_pointer((object *)executing);
		return executing;
	}
}

stack_frame *factor_vm::frame_successor(stack_frame *frame)
{
	check_frame(frame);
	return (stack_frame *)((cell)frame - frame->size);
}

/* Allocates memory */
cell factor_vm::frame_scan(stack_frame *frame)
{
	switch(frame_type(frame))
	{
	case QUOTATION_TYPE:
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
	case WORD_TYPE:
		return F;
	default:
		critical_error("Bad frame type",frame_type(frame));
		return F;
	}
}

namespace
{

struct stack_frame_accumulator {
	growable_array frames;

	stack_frame_accumulator(factor_vm *vm) : frames(vm) {} 

	void operator()(stack_frame *frame, factor_vm *myvm)
	{
		gc_root<object> executing(myvm->frame_executing(frame),myvm);
		gc_root<object> scan(myvm->frame_scan(frame),myvm);

		frames.add(executing.value());
		frames.add(scan.value());
	}
};

}

void factor_vm::primitive_callstack_to_array()
{
	gc_root<callstack> callstack(dpop(),this);

	stack_frame_accumulator accum(this);
	iterate_callstack_object(callstack.untagged(),accum);
	accum.frames.trim();

	dpush(accum.frames.elements.value());
}

stack_frame *factor_vm::innermost_stack_frame(callstack *stack)
{
	stack_frame *top = stack->top();
	stack_frame *bottom = stack->bottom();
	stack_frame *frame = bottom - 1;

	while(frame >= top && frame_successor(frame) >= top)
		frame = frame_successor(frame);

	return frame;
}

stack_frame *factor_vm::innermost_stack_frame_quot(callstack *callstack)
{
	stack_frame *inner = innermost_stack_frame(callstack);
	tagged<quotation>(frame_executing(inner)).untag_check(this);
	return inner;
}

/* Some primitives implementing a limited form of callstack mutation.
Used by the single stepper. */
void factor_vm::primitive_innermost_stack_frame_executing()
{
	dpush(frame_executing(innermost_stack_frame(untag_check<callstack>(dpop()))));
}

void factor_vm::primitive_innermost_stack_frame_scan()
{
	dpush(frame_scan(innermost_stack_frame_quot(untag_check<callstack>(dpop()))));
}

void factor_vm::primitive_set_innermost_stack_frame_quot()
{
	gc_root<callstack> callstack(dpop(),this);
	gc_root<quotation> quot(dpop(),this);

	callstack.untag_check(this);
	quot.untag_check(this);

	jit_compile(quot.value(),true);

	stack_frame *inner = innermost_stack_frame_quot(callstack.untagged());
	cell offset = (char *)FRAME_RETURN_ADDRESS(inner) - (char *)inner->xt;
	inner->xt = quot->xt;
	FRAME_RETURN_ADDRESS(inner) = (char *)quot->xt + offset;
}

/* called before entry into Factor code. */
void factor_vm::save_callstack_bottom(stack_frame *callstack_bottom)
{
	stack_chain->callstack_bottom = callstack_bottom;
}

VM_ASM_API void save_callstack_bottom(stack_frame *callstack_bottom, factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->save_callstack_bottom(callstack_bottom);
}

}
