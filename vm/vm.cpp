#include "master.hpp"

namespace factor {

factor_vm::factor_vm(THREADHANDLE thread)
    : ctx(nullptr),
      nursery(0, 0),
      faulting_p(false),
      thread(thread),
      callback_id(0),
      c_to_factor_func(nullptr),
      sampling_profiler_p(false),
      signal_pipe_input(0),
      signal_pipe_output(0),
      current_sample(0, 0, 0, 0, 0),
      gc_off(false),
      current_gc_p(false),
      current_jit_count(0),
      fep_p(false),
      fep_help_was_shown(false),
      fep_disabled(false),
      full_output(false),
      object_counter(0),
      last_nano_count(0),
      safepoint_fep_p(false),
      stop_on_ctrl_break(false)
#if defined(WINDOWS)
      ,
      thread_id(GetCurrentThreadId()),
      ctrl_break_thread(nullptr),
      sampler_thread(nullptr)
#endif
{
  primitive_reset_dispatch_stats();
}

factor_vm::~factor_vm() {
  free(alien_offset(special_objects[OBJ_EXECUTABLE]));
  free(alien_offset(special_objects[OBJ_IMAGE]));
  close_console();
  FACTOR_ASSERT(!ctx);
  
  // Clean up unused contexts
  for (auto* context : unused_contexts) {
    delete context;
  }
  
  // Clean up active contexts
  for (auto* context : active_contexts) {
    delete context;
  }
  
  // function_descriptors now uses unique_ptr, so they clean up automatically
  function_descriptors.clear();
}

}
