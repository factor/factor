#include "master.hpp"

namespace factor {

void factor_vm::c_to_factor(cell quot) {
  // First time this is called, wrap the c-to-factor sub-primitive inside
  // of a callback stub, which saves and restores non-volatile registers
  // per platform ABI conventions, so that the Factor compiler can treat
  // all registers as volatile
  if (!c_to_factor_func) {
    tagged<word> c_to_factor_word(special_objects[C_TO_FACTOR_WORD]);
    code_block* c_to_factor_block = callbacks->add(c_to_factor_word.value(), 0);
    cell func = c_to_factor_block->entry_point();
    CODE_TO_FUNCTION_POINTER_CALLBACK(this, func);
    c_to_factor_func = (c_to_factor_func_type) func;
  }
  jit_force_executable();
  c_to_factor_func(quot);
}

void factor_vm::unwind_native_frames(cell quot, cell to) {
#if defined(FACTOR_SPARC) && defined(__OpenBSD__)
  abandon_sparc_signals(ctx, to);
#endif
  tagged<word> entry_point_word(special_objects[UNWIND_NATIVE_FRAMES_WORD]);
  cell func = entry_point_word->entry_point;
  CODE_TO_FUNCTION_POINTER(func);
  // This is a non-local jump: the abandoned C frames between the fault and the
  // error handler never run their jit_writable_scope destructors, so the
  // thread may be left writable with no scope to restore it. Force executable
  // and reset the mode (Factor code always runs at the outermost, executable
  // state). Mirrors the Zig VM's resetForUnwind.
  jit_force_executable();
#ifdef FACTOR_PPC
  // Older PowerPC images omitted the generated unwind flag reset. Clear it
  // before abandoning C frames, as the Zig VM does for the same transition.
  faulting_p = false;
#endif
#if defined(FACTOR_HPPA)
  // HPPA's entry stub restores the upward native r30 from argument two.
  // Its Factor r18 frame comes from ctx->callstack_top independently.
  (void)to;
  ((unwind_native_frames_func_type) func)(quot, ctx->callstack_save);
#elif defined(FACTOR_M68K)
  if (m68k_legacy_unwind_arguments_p((const void*)func)) {
    // Preserve ordinary older images without rewriting their code heap.
    // Three dummy arguments put quot/to at the legacy entry's SP+16/SP+20.
    typedef void (*legacy_unwind_type)(cell, cell, cell, cell, cell);
    ((legacy_unwind_type)func)(0, 0, 0, quot, to);
  } else {
    ((unwind_native_frames_func_type)func)(quot, to);
  }
#else
  ((unwind_native_frames_func_type) func)(quot, to);
#endif
}

cell factor_vm::get_fpu_state() {
#if defined(FACTOR_VAX)
  return vax_get_fpu_state();
#elif defined(FACTOR_ALPHA)
  // Native callers may use Factor's R14 safepoint register for C++ data.
  // Read and reset FPCR without calling a Factor entry with safepoint stores.
  const cell nearest_bits = 0x0800000000000000ULL;
  double nearest;
  memcpy(&nearest, &nearest_bits, sizeof(nearest));
  double saved;
  asm volatile("mf_fpcr %0\n\tmt_fpcr %1"
               : "=&f"(saved) : "f"(nearest) : "memory");
  cell state;
  memcpy(&state, &saved, sizeof(state));
  return state;
#elif defined(FACTOR_S390X)
  // Native callers do not have Factor's reserved registers or frame layout.
  // The special word may have been optimized into ordinary Factor code.
  unsigned int state;
  unsigned int clear = 0;
  asm volatile("efpc %0\n\tsfpc %1" : "=&d"(state) : "d"(clear) : "memory");
  return state;
#else
  tagged<word> entry_point_word(special_objects[GET_FPU_STATE_WORD]);
  cell func = entry_point_word->entry_point;
  CODE_TO_FUNCTION_POINTER(func);
  return ((get_fpu_state_func_type) func)();
#endif
}

void factor_vm::set_fpu_state(cell state) {
#if defined(FACTOR_VAX)
  vax_set_fpu_state(state);
#elif defined(FACTOR_ALPHA)
  double control;
  memcpy(&control, &state, sizeof(control));
  asm volatile("mt_fpcr %0" : : "f"(control) : "memory");
#elif defined(FACTOR_S390X)
  unsigned int control = (unsigned int)state;
  asm volatile("sfpc %0" : : "d"(control) : "memory");
#else
  tagged<word> entry_point_word(special_objects[SET_FPU_STATE_WORD]);
  cell func = entry_point_word->entry_point;
  CODE_TO_FUNCTION_POINTER(func);
  ((set_fpu_state_func_type) func)(state);
#endif
}

}
