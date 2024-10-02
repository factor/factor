#include "master.hpp"

namespace factor {

void factor_vm::dispatch_signal_handler(cell* sp, cell* pc, cell newpc) {

  // bool in_code_seg = code->seg->in_segment_p(*pc);
  // cell cs_limit = ctx->callstack_seg->start + stack_reserved;
  // signal_resumable = in_code_seg && *sp >= cs_limit;

  // if (signal_resumable) {
  //   dispatch_resumable_signal(sp, pc, handler);
  // } else {
  //   dispatch_non_resumable_signal(sp, pc, handler, cs_limit);
  // }

  // Poking with the stack pointer, which the above code does, means
  // that pointers to stack-allocated objects will become
  // corrupted. Therefore the root vectors needs to be cleared because
  // their pointers to stack variables are now garbage.
  data_roots.clear();
  code_roots.clear();
}

}
