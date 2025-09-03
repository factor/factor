#include "master.hpp"

namespace factor {

void factor_vm::dispatch_non_resumable_signal(cell* sp, cell* pc,
                                              cell handler,
                                              cell limit) {

  // Fault came from the VM or foreign code. We don't try to fix the
  // call stack from *sp and instead use the last saved "good value"
  // which we get from ctx->callstack_top. Then launch the handler
  // without going through the resumable subprimitive.
  cell frame_top = ctx->callstack_top;
  cell seg_start = ctx->callstack_seg->start;

  if (frame_top < seg_start) {
    // The saved callstack pointer is outside the callstack
    // segment. That means that we need to carefully cut off one frame
    // first which hopefully should put the pointer within the
    // callstack's bounds.
    code_block *block = code->code_block_for_address(*pc);
    cell frame_size = block->stack_frame_size_for_address(*pc);
    frame_top += frame_size;
  }

  // Cut the callstack down to the shallowest Factor stack
  // frame that leaves room for the signal handler to do its thing,
  // and launch the handler without going through the resumable
  // subprimitive.
  FACTOR_ASSERT(seg_start <= frame_top);
  while (frame_top < ctx->callstack_bottom && frame_top < limit) {
    frame_top = code->frame_predecessor(frame_top);
  }
  ctx->callstack_top = frame_top;
  *sp = frame_top;
  *pc = handler;
}

void factor_vm::dispatch_resumable_signal(cell* sp, cell* pc, cell handler) {

  // Fault came from Factor, and we've got a good callstack. Route the
  // signal handler through the resumable signal handler
  // subprimitive.

  cell offset = *sp % 16;

  signal_handler_addr = handler;

  // True stack frames are always 16-byte aligned. Leaf procedures
  // that don't create a stack frame will be out of alignment by
  // sizeof(cell) bytes.
  // On architectures with a link register we would have to check for
  // leafness by matching the PC to a word. We should also use
  // FRAME_RETURN_ADDRESS instead of assuming the stack pointer is the
  // right place to put the resume address.
  cell index = 0;
  cell delta = 0;
  if (offset == 0) {
    delta = sizeof(cell);
    index = SIGNAL_HANDLER_WORD;
  } else if (offset == 16 - sizeof(cell)) {
    // Make a fake frame for the leaf procedure
    FACTOR_ASSERT(code->code_block_for_address(*pc) != NULL);
    delta = LEAF_FRAME_SIZE;
    index = LEAF_SIGNAL_HANDLER_WORD;
  } else {
    FACTOR_ASSERT(false);
  }
  cell new_sp = *sp - delta;
  *sp = new_sp;
  *(cell*)new_sp = *pc;

  *pc = untag<word>(special_objects[index])->entry_point;
}

void factor_vm::dispatch_signal_handler(cell* sp, cell* pc, cell handler) {

  bool in_code_seg = code->seg->in_segment_p(*pc);
  cell cs_limit = ctx->callstack_seg->start + stack_reserved;
  signal_resumable = in_code_seg && *sp >= cs_limit;

  if (signal_resumable) {
    dispatch_resumable_signal(sp, pc, handler);
  } else {
    dispatch_non_resumable_signal(sp, pc, handler, cs_limit);
  }

  // Poking with the stack pointer, which the above code does, means
  // that pointers to stack-allocated objects will become
  // corrupted. Therefore the root vectors needs to be cleared because
  // their pointers to stack variables are now garbage.
  data_roots.clear();
  code_roots.clear();
}

}
