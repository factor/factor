// Copyright (C) 2026 Doug Coleman. BSD license.
#include <signal.h>
#include "sparc-openbsd-context.h"

namespace factor {
#define UAP_STACK_POINTER(raw) (((struct sigcontext*)(raw))->sc_sp)
#define UAP_PROGRAM_COUNTER(raw) (((struct sigcontext*)(raw))->sc_pc)
inline auto& sparc_signal_sp(void* raw) { return UAP_STACK_POINTER(raw); }
inline auto& sparc_signal_pc(void* raw) { return UAP_PROGRAM_COUNTER(raw); }
inline auto& sparc_signal_npc(void* raw) {
  return ((struct sigcontext*)raw)->sc_npc;
}
inline cell sparc_signal_stack_address(void* raw) {
  return sparc_signal_sp(raw) + 2047;
}
inline void sparc_redirect_signal(void* raw, cell target) {
  sparc_signal_pc(raw) = target;
  sparc_signal_npc(raw) = target + 4;
}
inline void flush_icache(cell start, cell length) {
  __builtin___clear_cache((char*)start, (char*)(start + length));
}
inline unsigned uap_fpu_status(void* raw) {
  return factor_sparc_openbsd_fpu_status(raw);
}
inline void uap_clear_fpu_status(void* raw) {
  factor_sparc_openbsd_clear_fpu_status(raw);
}
inline unsigned fpu_status(unsigned status) {
  unsigned result = 0;
  if (status & 0x10) result |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x08) result |= FP_TRAP_OVERFLOW;
  if (status & 0x04) result |= FP_TRAP_UNDERFLOW;
  if (status & 0x02) result |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x01) result |= FP_TRAP_INEXACT;
  return result;
}
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}
