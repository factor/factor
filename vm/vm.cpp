#include "master.hpp"

namespace factor {

factor_vm::factor_vm(THREADHANDLE thread)
    : ctx(NULL),
      nursery(0, 0),
      faulting_p(false),
      thread(thread),
      callback_id(0),
      c_to_factor_func(NULL),
      sampling_profiler_p(false),
      signal_pipe_input(0),
      signal_pipe_output(0),
      current_sample(0, 0, 0, 0, 0),
      gc_off(false),
      data(NULL), code(NULL), callbacks(NULL),
      current_gc(NULL),
      current_gc_p(false),
      current_jit_count(0),
      gc_events(NULL),
      fep_p(false),
      fep_help_was_shown(false),
      fep_disabled(false),
      full_output(false),
      object_counter(0),
      last_nano_count(0),
      signal_callstack_seg(NULL),
      safepoint_fep_p(false),
      stop_on_ctrl_break(false)
#if defined(WINDOWS)
      ,
      thread_id(GetCurrentThreadId()),
      ctrl_break_thread(NULL),
      sampler_thread(NULL)
#endif
{
  // Most runtime calls only need a handful of temporary roots. Reserve the
  // hot-path storage once so constructing data_root/code_root handles does not
  // repeatedly grow malloc-side vectors while compiling or handling PIC misses.
  data_roots.reserve(256);
  code_roots.reserve(16);
  primitive_reset_dispatch_stats();
}

factor_vm::~factor_vm() {
  free_vm_paths();
  close_console();
  FACTOR_ASSERT(!ctx);
  FACTOR_FOR_EACH(unused_contexts) {
    delete *iter;
  }
  FACTOR_FOR_EACH(active_contexts) {
    delete *iter;
  }
  if (callbacks)
    delete callbacks;
  if (data)
    delete data;
  if (code)
    delete code;
  if (signal_callstack_seg) {
    delete signal_callstack_seg;
    signal_callstack_seg = NULL;
  }
  FACTOR_FOR_EACH(function_descriptors) {
    delete[] * iter;
  }
}

void factor_vm::free_vm_paths() {
  cell path_indexes[] = {OBJ_EXECUTABLE, OBJ_IMAGE};
  for (cell index : path_indexes) {
    cell path = special_objects[index];
    if (path != false_object) {
      special_objects[index] = false_object;
      free(alien_offset(path));
    }
  }
}

}
