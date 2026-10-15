#pragma once

namespace factor::platform {
inline void dispatch_signal(factor_vm& vm, void* uap, void(handler)()) {
  vm.dispatch_ppc_signal((cell*)&UAP_STACK_POINTER(uap),
                      (cell*)&UAP_PROGRAM_COUNTER(uap),
                      (cell)UAP_LINK_REGISTER(uap),
                      (cell)FUNCTION_CODE_POINTER(handler));
#ifdef FACTOR_PPC_TOC
  if (vm.signal_resumable) vm.signal_handler_addr = (cell)handler;
#endif
  if (!vm.signal_resumable) {
#if defined(UAP_GLOBAL_ENTRY_REGISTER)
    UAP_GLOBAL_ENTRY_REGISTER(uap) = (cell)FUNCTION_CODE_POINTER(handler);
#endif
#if defined(UAP_TOC_REGISTER)
    UAP_TOC_REGISTER(uap) = (cell)FUNCTION_TOC_POINTER(handler);
#endif
  }
}
}
