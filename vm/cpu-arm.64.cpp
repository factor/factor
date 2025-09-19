#include "master.hpp"

namespace factor {

void factor_vm::dispatch_non_resumable_signal(cell* sp, cell* pc, cell handler, cell limit) {

  cell frame_top = ctx->callstack_top;
  cell seg_start = ctx->callstack_seg->start;

  if (frame_top < seg_start) {
    code_block *block = code->code_block_for_address(*pc);
    cell frame_size = block->stack_frame_size_for_address(*pc);
    frame_top += frame_size;
  }

  FACTOR_ASSERT(seg_start <= frame_top);
  while (frame_top < ctx->callstack_bottom && frame_top < limit) {
    frame_top = code->frame_predecessor(frame_top);
  }
  ctx->callstack_top = frame_top;
  *sp = frame_top;
  *pc = handler;
}

void factor_vm::dispatch_resumable_signal(cell* sp, cell* pc, cell handler) {

  signal_handler_addr = handler;
  *reinterpret_cast<cell*>(*sp - 16) = *sp;
  *reinterpret_cast<cell*>(*sp - 8) = *pc;
  *sp -= 16;
  *pc = untag<word>(special_objects[SIGNAL_HANDLER_WORD])->entry_point;
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

  data_roots.clear();
  code_roots.clear();
}

}
