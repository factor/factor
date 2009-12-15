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

/* We ignore the two topmost frames, the 'callstack' primitive
frame itself, and the frame calling the 'callstack' primitive,
so that set-callstack doesn't get stuck in an infinite loop.

This means that if 'callstack' is called in tail position, we
will have popped a necessary frame... however this word is only
called by continuation implementation, and user code shouldn't
be calling it at all, so we leave it as it is for now. */
stack_frame *factor_vm::second_from_top_stack_frame()
{
	stack_frame *frame = ctx->callstack_bottom - 1;
	while(frame >= ctx->callstack_top
		&& frame_successor(frame) >= ctx->callstack_top
		&& frame_successor(frame_successor(frame)) >= ctx->callstack_top)
	{
		frame = frame_successor(frame);
	}
	return frame + 1;
}

void factor_vm::primitive_callstack()
{
	stack_frame *top = second_from_top_stack_frame();
	stack_frame *bottom = ctx->callstack_bottom;

	fixnum size = std::max((fixnum)0,(fixnum)bottom - (fixnum)top);

	callstack *stack = allot_callstack(size);
	memcpy(stack->top(),top,size);
	dpush(tag<callstack>(stack));
}

void factor_vm::primitive_set_callstack()
{
	callstack *stack = untag_check<callstack>(dpop());

	set_callstack(ctx->callstack_bottom,
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

code_block_type factor_vm::frame_type(stack_frame *frame)
{
	return frame_code(frame)->type();
}

cell factor_vm::frame_executing(stack_frame *frame)
{
	return frame_code(frame)->owner;
}

cell factor_vm::frame_executing_quot(stack_frame *frame)
{
	tagged<object> executing(frame_executing(frame));
	code_block *compiled = frame_code(frame);
	if(!compiled->optimized_p() && executing->type() == WORD_TYPE)
		executing = executing.as<word>()->def;
	return executing.value();
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
	case code_block_unoptimized:
		{
			tagged<object> obj(frame_executing(frame));
			if(obj.type_p(WORD_TYPE))
				obj = obj.as<word>()->def;

			if(obj.type_p(QUOTATION_TYPE))
			{
				char *return_addr = (char *)FRAME_RETURN_ADDRESS(frame,this);
				char *quot_xt = (char *)(frame_code(frame) + 1);

				return tag_fixnum(quot_code_offset_to_scan(
					obj.value(),(cell)(return_addr - quot_xt)));
			}    
			else
				return false_object;
		}
	case code_block_optimized:
		return false_object;
	default:
		critical_error("Bad frame type",frame_type(frame));
		return false_object;
	}
}

namespace
{

struct stack_frame_accumulator {
	factor_vm *parent;
	growable_array frames;

	explicit stack_frame_accumulator(factor_vm *parent_) : parent(parent_), frames(parent_) {} 

	void operator()(stack_frame *frame)
	{
		data_root<object> executing(parent->frame_executing_quot(frame),parent);
		data_root<object> scan(parent->frame_scan(frame),parent);

		frames.add(executing.value());
		frames.add(scan.value());
	}
};

}

void factor_vm::primitive_callstack_to_array()
{
	data_root<callstack> callstack(dpop(),this);

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

/* Some primitives implementing a limited form of callstack mutation.
Used by the single stepper. */
void factor_vm::primitive_innermost_stack_frame_executing()
{
	stack_frame *frame = innermost_stack_frame(untag_check<callstack>(dpop()));
	dpush(frame_executing_quot(frame));
}

void factor_vm::primitive_innermost_stack_frame_scan()
{
	stack_frame *frame = innermost_stack_frame(untag_check<callstack>(dpop()));
	dpush(frame_scan(frame));
}

void factor_vm::primitive_set_innermost_stack_frame_quot()
{
	data_root<callstack> callstack(dpop(),this);
	data_root<quotation> quot(dpop(),this);

	callstack.untag_check(this);
	quot.untag_check(this);

	jit_compile_quot(quot.value(),true);

	stack_frame *inner = innermost_stack_frame(callstack.untagged());
	cell offset = (char *)FRAME_RETURN_ADDRESS(inner,this) - (char *)inner->xt;
	inner->xt = quot->xt;
	FRAME_RETURN_ADDRESS(inner,this) = (char *)quot->xt + offset;
}

/* called before entry into Factor code. */
void factor_vm::save_callstack_bottom(stack_frame *callstack_bottom)
{
	ctx->callstack_bottom = callstack_bottom;
}

VM_ASM_API void save_callstack_bottom(stack_frame *callstack_bottom, factor_vm *parent)
{
	return parent->save_callstack_bottom(callstack_bottom);
}

}
