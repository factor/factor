#pragma once

namespace factor::platform {
inline void dispatch_signal(factor_vm& vm, void* uap, void(handler)()) {
  vm.dispatch_signal_handler((cell*)&UAP_STACK_POINTER(uap),
                          (cell*)&UAP_PROGRAM_COUNTER(uap),
                          (cell)FUNCTION_CODE_POINTER(handler));
#if defined(__linux__) && defined(FACTOR_ARM32)
  arm32_signal_set_entry(uap, UAP_PROGRAM_COUNTER(uap));
#endif
#if defined(__NetBSD__) && defined(FACTOR_VAX)
  if (!vm.signal_resumable) {
    // A native VAX entry starts with a CALLS mask, not an instruction.
    UAP_NATIVE_HANDLER_REGISTER(uap) = (cell)handler;
    UAP_PROGRAM_COUNTER(uap) = (cell)vax_non_resumable_signal_entry;
  }
#endif
#ifdef UAP_NATIVE_ENTRY
  // Native PIC entry derives gp from t9 (MIPS) or pv (Alpha). A PC-only
  // redirection retains the interrupted callee's entry register.
  if (!vm.signal_resumable) UAP_NATIVE_ENTRY(uap, UAP_PROGRAM_COUNTER(uap));
#endif
}
}
