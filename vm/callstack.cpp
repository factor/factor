#include "master.hpp"

namespace factor
{

void factor_vm::check_frame(stack_frame *frame)
{
#ifdef FACTOR_DEBUG
	check_code_pointer((cell)frame->entry_point);
	FACTOR_ASSERT(frame->size != 0);
#endif
}

callstack *factor_vm::allot_callstack(cell size)
{
	callstack *stack = allot<callstack>(callstack_object_size(size));
	stack->length = tag_fixnum(size);
	return stack;
}

/* We ignore the two topmost frames, the 'callstack' primitive
frame itself, and the frame calling the 'callstack' primitive,
so that set-callstack doesn't get stuck in an infinite loop.

This means that if 'callstack' is called in tail position, we
will have popped a necessary frame... however this word is only
called by continuation implementation, and user code shouldn't
be calling it at all, so we leave it as it is for now. */
stack_frame *factor_vm::second_from_top_stack_frame(context *ctx)
{
	stack_frame *frame = ctx->bottom_frame();
	while(frame >= ctx->callstack_top
		&& frame_successor(frame) >= ctx->callstack_top
		&& frame_successor(frame_successor(frame)) >= ctx->callstack_top)
	{
		frame = frame_successor(frame);
	}
	return frame + 1;
}

cell factor_vm::capture_callstack(context *ctx)
{
	stack_frame *top = second_from_top_stack_frame(ctx);
	stack_frame *bottom = ctx->callstack_bottom;

	fixnum size = std::max((fixnum)0,(fixnum)bottom - (fixnum)top);

	callstack *stack = allot_callstack(size);
	memcpy(stack->top(),top,size);
	return tag<callstack>(stack);
}

void factor_vm::primitive_callstack()
{
	ctx->push(capture_callstack(ctx));
}

void factor_vm::primitive_callstack_for()
{
	context *other_ctx = (context *)pinned_alien_offset(ctx->pop());
	ctx->push(capture_callstack(other_ctx));
}

code_block *factor_vm::frame_code(stack_frame *frame)
{
	check_frame(frame);
	return (code_block *)frame->entry_point - 1;
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
	return frame_code(frame)->owner_quot();
}

stack_frame *factor_vm::frame_successor(stack_frame *frame)
{
	check_frame(frame);
	return (stack_frame *)((cell)frame - frame->size);
}

cell factor_vm::frame_offset(stack_frame *frame)
{
	char *return_address = (char *)FRAME_RETURN_ADDRESS(frame,this);
	FACTOR_ASSERT(return_address != 0);
	return frame_code(frame)->offset(return_address);
}

void factor_vm::set_frame_offset(stack_frame *frame, cell offset)
{
	char *entry_point = (char *)frame_code(frame)->entry_point();
	FRAME_RETURN_ADDRESS(frame,this) = entry_point + offset;
}

cell factor_vm::frame_scan(stack_frame *frame)
{
	return frame_code(frame)->scan(this, FRAME_RETURN_ADDRESS(frame,this));
}

struct stack_frame_accumulator {
	factor_vm *parent;
	growable_array frames;

	explicit stack_frame_accumulator(factor_vm *parent_)
		: parent(parent_), frames(parent_) {}

	void operator()(void *frame_top, cell frame_size, code_block *owner, void *addr)
	{
		data_root<object> executing_quot(owner->owner_quot(),parent);
		data_root<object> executing(owner->owner,parent);
		data_root<object> scan(owner->scan(parent, addr),parent);

		frames.add(executing.value());
		frames.add(executing_quot.value());
		frames.add(scan.value());
	}
};

struct stack_frame_in_array { cell cells[3]; };

void factor_vm::primitive_callstack_to_array()
{
	data_root<callstack> callstack(ctx->pop(),this);

	stack_frame_accumulator accum(this);
	iterate_callstack_object(callstack.untagged(),accum);

	/* The callstack iterator visits frames in reverse order (top to bottom) */
	std::reverse(
		(stack_frame_in_array*)accum.frames.elements->data(),
		(stack_frame_in_array*)(accum.frames.elements->data() + accum.frames.count));

	accum.frames.trim();

	ctx->push(accum.frames.elements.value());

}

stack_frame *factor_vm::innermost_stack_frame(stack_frame *bottom, stack_frame *top)
{
	stack_frame *frame = bottom - 1;

	while(frame >= top && frame_successor(frame) >= top)
		frame = frame_successor(frame);

	return frame;
}

/* Some primitives implementing a limited form of callstack mutation.
Used by the single stepper. */
void factor_vm::primitive_innermost_stack_frame_executing()
{
	callstack *stack = untag_check<callstack>(ctx->pop());
	stack_frame *frame = innermost_stack_frame(stack->bottom(), stack->top());
	ctx->push(frame_executing_quot(frame));
}

void factor_vm::primitive_innermost_stack_frame_scan()
{
	callstack *stack = untag_check<callstack>(ctx->pop());
	stack_frame *frame = innermost_stack_frame(stack->bottom(), stack->top());
	ctx->push(frame_scan(frame));
}

void factor_vm::primitive_set_innermost_stack_frame_quot()
{
	data_root<callstack> stack(ctx->pop(),this);
	data_root<quotation> quot(ctx->pop(),this);

	stack.untag_check(this);
	quot.untag_check(this);

	jit_compile_quot(quot.value(),true);

	stack_frame *inner = innermost_stack_frame(stack->bottom(), stack->top());
	cell offset = frame_offset(inner);
	inner->entry_point = quot->entry_point;
	set_frame_offset(inner,offset);
}

void factor_vm::primitive_callstack_bounds()
{
	ctx->push(allot_alien((void*)ctx->callstack_seg->start));
	ctx->push(allot_alien((void*)ctx->callstack_seg->end));
}

}
