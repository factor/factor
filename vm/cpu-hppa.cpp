#include "master.hpp"

namespace factor {

// GNU millicode implements the division missing from the ISA. Keep the
// signed overflow boundary defined for machine arithmetic callers.
extern "C" int32_t hppa_divide_i32(int32_t lhs, int32_t rhs) {
  if (lhs == INT32_MIN && rhs == -1) return INT32_MIN;
  return lhs / rhs;
}
extern "C" int32_t hppa_remainder_i32(int32_t lhs, int32_t rhs) {
  if (lhs == INT32_MIN && rhs == -1) return 0;
  return lhs % rhs;
}


void factor_vm::dispatch_non_resumable_signal(cell* sp, cell* pc, cell handler, cell limit) {
  cell frame_top = ctx->callstack_top;
  cell seg_start = ctx->callstack_seg->start;

  if (frame_top < seg_start) {
    frame_top = *(cell*)frame_top;
  }

  FACTOR_ASSERT(seg_start <= frame_top);
  while (frame_top < ctx->callstack_bottom && frame_top < limit) {
    frame_top = *(cell*)frame_top;
  }
  ctx->callstack_top = frame_top;
  *sp = frame_top;
  *pc = handler;
}

void factor_vm::dispatch_resumable_signal(cell* sp, cell* pc, cell handler) {
  signal_handler_addr = handler;

  cell index = SIGNAL_HANDLER_WORD;
  cell delta = 16;
  code_block* block = code->code_block_for_address(*pc);
  tagged<word> leaf_handler(special_objects[LEAF_SIGNAL_HANDLER_WORD]);
  if ((block->stack_frame_size() == 0 || *pc == block->entry_point()) &&
      leaf_handler.type_p() && to_boolean(leaf_handler->subprimitive)) {
    index = LEAF_SIGNAL_HANDLER_WORD;
    delta += LEAF_FRAME_SIZE;
  }

  cell previous = *sp;
  *sp -= delta;
  *(cell*)*sp = previous;
  *(cell*)(*sp + FRAME_RETURN_ADDRESS) = *pc;
  if (index == LEAF_SIGNAL_HANDLER_WORD) {
    // The interrupted leaf has no header containing its live return register.
    // Keep both its PC and its caller's PC in the predecessor-SP chain.
    *(cell*)*sp = *sp + LEAF_FRAME_SIZE;
    *(cell*)(*sp + LEAF_FRAME_SIZE) = previous;
  }
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

  data_roots.clear();
  code_roots.clear();
}

}
