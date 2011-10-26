#include "master.hpp"

namespace factor
{

void factor_vm::check_frame(stack_frame *frame)
{
#ifdef FACTOR_DEBUG
	check_code_pointer((cell)frame->entry_point);
	assert(frame->size != 0);
#endif
}

callstack *factor_vm::allot_callstack(cell size)
{
	callstack *stack = allot<callstack>(callstack_object_size(size));
	stack->length = tag_fixnum(size);
	return stack;
}

// XXX move somewhere more appropriate
struct word_finder {
	cell address;
	cell found_word;

	word_finder(cell address) : address(address), found_word(0) {}

	bool in_code_block_p(code_block *code, cell address)
	{
		return ((cell)code->entry_point() <= address 
				&& address - (cell)code->entry_point() < code->size());
	}

	void save_found_word(cell entry_point)
	{
		assert(found_word == 0);
		found_word = entry_point;
	}

	// XXX keep a map of code blocks in the code heap so we don't need this
	void operator()(object *obj)
	{
		if (obj->type() == WORD_TYPE)
		{
			word *w = static_cast<word*>(obj);
			if (in_code_block_p(w->code, address))
				save_found_word((cell)w->code->entry_point());
			if (w->profiling && in_code_block_p(w->profiling, address))
				save_found_word((cell)w->profiling->entry_point());
		}
		else if (obj->type() == QUOTATION_TYPE)
		{
			quotation *q = static_cast<quotation*>(obj);
			if (in_code_block_p(q->code, address))
				save_found_word((cell)q->code->entry_point());
		}
	}
};

static cell find_word_for_address(factor_vm *vm, cell pc)
{
	word_finder finder(pc);
	vm->each_object(finder);
	assert(finder.found_word != 0);
	return finder.found_word;
}

void factor_vm::dispatch_signal_handler(cell *sp, cell *pc, cell handler)
{
	if (!code->seg->in_segment_p(*pc) || *sp < ctx->callstack_seg->start + stack_reserved)
	{
		/* Fault came from foreign code, a callstack overflow, or we would probably
		overflow if we tried the resumable handler. We can't resume, so cut the
		callstack down to the shallowest Factor stack frame that leaves room for
		the signal handler to do its thing and launch the handler without going
		through the resumable subprimitive. */
		signal_resumable = false;
		stack_frame *frame = ctx->callstack_bottom - 1;

		while((cell)frame >= *sp
			&& frame >= ctx->callstack_top
			&& (cell)frame >= ctx->callstack_seg->start + stack_reserved)
		{
			frame = frame_successor(frame);
		}

		// XXX FRAME_RETURN_ADDRESS
		cell newsp = (cell)(frame+1);
		*sp = newsp;
		ctx->callstack_top = (stack_frame*)newsp;
		*pc = handler;
	} else {
		signal_resumable = true;
		// Fault came from Factor, and we've got a good callstack. Route the signal
		// handler through the resumable signal handler subprimitive.
		cell offset = *sp % 16;

		signal_handler_addr = handler;
		tagged<word> handler_word = tagged<word>(special_objects[SIGNAL_HANDLER_WORD]);

		/* XXX horribly x86-centric */
		/* True stack frames are always 16-byte aligned. Leaf procedures
		that don't create a stack frame will be out of alignment by sizeof(cell)
		bytes. */
		/* On architectures with a link register we would have to check for leafness
		by matching the PC to a word. We should also use FRAME_RETURN_ADDRESS instead
		of assuming the stack pointer is the right place to put the resume address. */
		if (offset == 0)
		{
			signal_from_leaf = false; // XXX remove this once we're sure leaf works
			cell newsp = *sp - sizeof(cell);
			*sp = newsp;
			*(cell*)newsp = *pc;
		}
		else if (offset == 16 - sizeof(cell))
		{
			signal_from_leaf = true; // XXX remove this once we're sure leaf works

			// Make a fake frame for the leaf procedure
			cell leaf_word = find_word_for_address(this, *pc);

			// XXX get platform-appropriate stack frame size
			cell newsp = *sp - 32;
			*(cell*)(newsp + 32 -   sizeof(cell)) = 32;
			*(cell*)(newsp + 32 - 2*sizeof(cell)) = leaf_word;
			*(cell*) newsp                        = *pc;
			*sp = newsp;
			handler_word = tagged<word>(special_objects[LEAF_SIGNAL_HANDLER_WORD]);
		}
		else
		{
			fatal_error("Invalid stack frame during signal handler", *sp);
		}

		*pc = (cell)handler_word->code->entry_point();
	}
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
	stack_frame *frame = ctx->callstack_bottom - 1;
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

cell factor_vm::frame_offset(stack_frame *frame)
{
	char *entry_point = (char *)frame_code(frame)->entry_point();
	char *return_address = (char *)FRAME_RETURN_ADDRESS(frame,this);
	if(return_address)
		return return_address - entry_point;
	else
		return (cell)-1;
}

void factor_vm::set_frame_offset(stack_frame *frame, cell offset)
{
	char *entry_point = (char *)frame_code(frame)->entry_point();
	if(offset == (cell)-1)
		FRAME_RETURN_ADDRESS(frame,this) = NULL;
	else
		FRAME_RETURN_ADDRESS(frame,this) = entry_point + offset;
}

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
				return tag_fixnum(quot_code_offset_to_scan(obj.value(),frame_offset(frame)));
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

struct stack_frame_accumulator {
	factor_vm *parent;
	growable_array frames;

	explicit stack_frame_accumulator(factor_vm *parent_) : parent(parent_), frames(parent_) {} 

	void operator()(stack_frame *frame)
	{
		data_root<object> executing_quot(parent->frame_executing_quot(frame),parent);
		data_root<object> executing(parent->frame_executing(frame),parent);
		data_root<object> scan(parent->frame_scan(frame),parent);

		frames.add(executing.value());
		frames.add(executing_quot.value());
		frames.add(scan.value());
	}
};

void factor_vm::primitive_callstack_to_array()
{
	data_root<callstack> callstack(ctx->pop(),this);

	stack_frame_accumulator accum(this);
	iterate_callstack_object(callstack.untagged(),accum);
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
