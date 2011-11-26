#include "master.hpp"

namespace factor
{

void factor_vm::dispatch_signal_handler(cell *sp, cell *pc, cell handler)
{
	if (!code->seg->in_segment_p(*pc) || *sp < ctx->callstack_seg->start + stack_reserved)
	{
		/* Fault came from foreign code or a callstack overflow, or we don't
		have enough callstack room to try the resumable handler. Cut the
		callstack down to the shallowest Factor stack frame that leaves room for
		the signal handler to do its thing, and launch the handler without going
		through the resumable subprimitive. */
		signal_resumable = false;
		stack_frame *frame = ctx->bottom_frame();

		while((cell)frame >= *sp
			&& frame >= ctx->callstack_top
			&& (cell)frame >= ctx->callstack_seg->start + stack_reserved)
		{
			frame = frame_successor(frame);
		}

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

		/* True stack frames are always 16-byte aligned. Leaf procedures
		that don't create a stack frame will be out of alignment by sizeof(cell)
		bytes. */
		/* On architectures with a link register we would have to check for leafness
		by matching the PC to a word. We should also use FRAME_RETURN_ADDRESS instead
		of assuming the stack pointer is the right place to put the resume address. */
		if (offset == 0)
		{
			cell newsp = *sp - sizeof(cell);
			*sp = newsp;
			*(cell*)newsp = *pc;
		}
		else if (offset == 16 - sizeof(cell))
		{
			// Make a fake frame for the leaf procedure
			code_block *leaf_block = code->code_block_for_address(*pc);
			FACTOR_ASSERT(leaf_block != NULL);

			cell newsp = *sp - LEAF_FRAME_SIZE;
			*(cell*)(newsp + 3*sizeof(cell)) = 4*sizeof(cell);
			*(cell*)(newsp + 2*sizeof(cell)) = (cell)leaf_block->entry_point();
			*(cell*) newsp                   = *pc;
			*sp = newsp;
			handler_word = tagged<word>(special_objects[LEAF_SIGNAL_HANDLER_WORD]);
		}
		else
			FACTOR_ASSERT(false);

		*pc = (cell)handler_word->entry_point;
	}
}

}
