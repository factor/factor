#pragma once

namespace factor::platform {
inline void dispatch_signal(factor_vm& vm, void* uap, void(handler)()) {
  struct reg* regs = m88k_signal_registers(uap);
  cell sp = regs->r[31];
  cell pc = regs->sxip & XIP_ADDR;
  vm.dispatch_signal_handler(&sp, &pc, (cell)FUNCTION_CODE_POINTER(handler));
  regs->r[31] = sp;
  // OpenBSD sigreturn resumes the next/future instruction pipeline slots.
  regs->snip = pc | NIP_V;
  regs->sfip = (pc + 4) | FIP_V;
  // The redirected handler replaces the interrupted memory operation.
  // OpenBSD restores the saved data pipeline on sigreturn; leaving DMT0
  // valid can replay the failed access before the new instruction pointer.
  regs->dmt0 = 0;
}
}
