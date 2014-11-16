#include "master.hpp"

namespace factor {

void factor_vm::dispatch_signal_handler(cell* sp, cell* pc, cell handler) {
  if (!code->seg->in_segment_p(*pc) ||
      *sp < ctx->callstack_seg->start + stack_reserved) {
    /* Fault came from the VM, foreign code, a callstack overflow, or
       we don't have enough callstack room to try the resumable
       handler. Cut the callstack down to the shallowest Factor stack
       frame that leaves room for the signal handler to do its thing,
       and launch the handler without going through the resumable
       subprimitive. */
    signal_resumable = false;
    void* frame_top = (void*)ctx->callstack_top;

    while (frame_top < ctx->callstack_bottom &&
           (cell)frame_top < ctx->callstack_seg->start + stack_reserved) {
      frame_top = frame_predecessor(frame_top);
    }

    *sp = (cell)frame_top;
    ctx->callstack_top = frame_top;
    *pc = handler;
  } else {
    signal_resumable = true;
    /* Fault came from Factor, and we've got a good callstack. Route
       the signal handler through the resumable signal handler subprimitive. */
    cell offset = *sp % 16;

    signal_handler_addr = handler;
    tagged<word> handler_word =
        tagged<word>(special_objects[SIGNAL_HANDLER_WORD]);

    /* True stack frames are always 16-byte aligned. Leaf procedures
       that don't create a stack frame will be out of alignment by sizeof(cell)
       bytes. */
    /* On architectures with a link register we would have to check for leafness
       by matching the PC to a word. We should also use FRAME_RETURN_ADDRESS
       instead of assuming the stack pointer is the right place to put the
       resume address. */
    if (offset == 0) {
      cell newsp = *sp - sizeof(cell);
      *sp = newsp;
      *(cell*)newsp = *pc;
    } else if (offset == 16 - sizeof(cell)) {
      /* Make a fake frame for the leaf procedure */
      FACTOR_ASSERT(code->code_block_for_address(*pc) != NULL);

      cell newsp = *sp - LEAF_FRAME_SIZE;
      *(cell*)newsp = *pc;
      *sp = newsp;
      handler_word = tagged<word>(special_objects[LEAF_SIGNAL_HANDLER_WORD]);
    } else
      FACTOR_ASSERT(false);

    *pc = (cell)handler_word->entry_point;
  }

  /* Poking with the stack pointer, which the above code does, means
     that pointers to stack-allocated objects will become
     corrupted. Therefore the root vectors needs to be cleared because
     their pointers to stack variables are now garbage. */
  data_roots.clear();
  code_roots.clear();
}

}
