#include "master.hpp"

namespace factor {

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
  cell delta = JIT_FRAME_SIZE;
  code_block* block = code->code_block_for_address(*pc);
  tagged<word> leaf_handler(special_objects[LEAF_SIGNAL_HANDLER_WORD]);
  if ((block->stack_frame_size() == 0 || *pc == block->entry_point()) &&
      leaf_handler.type_p() && to_boolean(leaf_handler->subprimitive)) {
    index = LEAF_SIGNAL_HANDLER_WORD;
    delta += LEAF_FRAME_SIZE;
  }

  *sp -= delta;
  *(cell*)(*sp + FRAME_RETURN_ADDRESS) = *pc;
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

namespace factor {
// Alpha has no integer divide instruction. Keep the bootstrap's stack and
// allocation contracts in the VM while the optimizer lowers division calls.
VM_C_API void alpha_fixnum_mod(factor_vm* vm) {
  fixnum y = untag_fixnum(vm->ctx->pop());
  fixnum x = untag_fixnum(vm->ctx->peek());
  if (!y) vm->divide_by_zero_error();
  vm->ctx->replace(tag_fixnum(x % y));
}
VM_C_API void alpha_fixnum_divide(factor_vm* vm) {
  vm->primitive_fixnum_divint();
}
VM_C_API void alpha_fixnum_divmod(factor_vm* vm) {
  vm->primitive_fixnum_divmod();
}
VM_C_API void alpha_fixnum_add(factor_vm* vm) {
  fixnum y = untag_fixnum(vm->ctx->pop());
  fixnum x = untag_fixnum(vm->ctx->peek());
  vm->ctx->replace(vm->from_signed_cell(x + y));
}
VM_C_API void alpha_fixnum_subtract(factor_vm* vm) {
  fixnum y = untag_fixnum(vm->ctx->pop());
  fixnum x = untag_fixnum(vm->ctx->peek());
  vm->ctx->replace(vm->from_signed_cell(x - y));
}
VM_C_API void alpha_fixnum_multiply(factor_vm* vm) {
  fixnum y = untag_fixnum(vm->ctx->pop());
  fixnum x = untag_fixnum(vm->ctx->peek());
  fixnum result;
  if (__builtin_mul_overflow(x, y, &result))
    overflow_fixnum_multiply(x, y, vm);
  else
    vm->ctx->replace(vm->from_signed_cell(result));
}
}
