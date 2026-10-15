#pragma once

namespace factor::platform {
inline void dispatch_signal(factor_vm& vm, void* uap, void(handler)()) {
  cell hppa_sp = UAP_STACK_POINTER(uap);
  cell hppa_pc = UAP_PROGRAM_COUNTER(uap) & ~cell(3);
  vm.dispatch_signal_handler(&hppa_sp, &hppa_pc, (cell)FUNCTION_CODE_POINTER(handler));
  UAP_STACK_POINTER(uap) = hppa_sp;
  UAP_PROGRAM_COUNTER(uap) = hppa_pc | 3;
  UAP_NEXT_PROGRAM_COUNTER(uap) = (hppa_pc + 4) | 3;
  if (vm.signal_resumable) vm.signal_handler_addr = (cell)handler;
  else UAP_GLOBAL_POINTER(uap) = FUNCTION_TOC_POINTER(handler);
}
}
