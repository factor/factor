#include "master.hpp"

namespace factor {

factor_vm::factor_vm(THREADHANDLE thread)
    : nursery(0, 0),
      faulting_p(false),
      thread(thread),
      callback_id(0),
      c_to_factor_func(NULL),
      sampling_profiler_p(false),
      signal_pipe_input(0),
      signal_pipe_output(0),
      gc_off(false),
      current_gc(NULL),
      current_gc_p(false),
      current_jit_count(0),
      gc_events(NULL),
      fep_p(false),
      fep_help_was_shown(false),
      fep_disabled(false),
      full_output(false),
      last_nano_count(0),
      signal_callstack_seg(NULL),
      safepoint() {
  primitive_reset_dispatch_stats();
}

factor_vm::~factor_vm() {
  delete_contexts();
  if (signal_callstack_seg) {
    delete signal_callstack_seg;
    signal_callstack_seg = NULL;
  }
  FACTOR_FOR_EACH(function_descriptors) {
    delete[] * iter;
  }
}

}
