#include <signal.h>
#include <ucontext.h>
#include "software_fp_state.hpp"

namespace factor {

#define UAP_STACK_POINTER(uap) _UC_MACHINE_SP((ucontext_t*)uap)
#define UAP_PROGRAM_COUNTER(uap) _UC_MACHINE_PC((ucontext_t*)uap)
#define UAP_NATIVE_HANDLER_REGISTER(uap) \
  (((ucontext_t*)uap)->uc_mcontext.__gregs[_REG_R0])

extern "C" void vax_non_resumable_signal_entry();

inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char*)start, (char*)(start + len));
}

// VAX has no separate FPU save area or accrued IEEE exception register.
inline static unsigned int uap_fpu_status(void*) { return software_fp_flags; }
inline static void uap_clear_fpu_status(void*) { software_fp_flags = 0; }

inline static unsigned int fpu_status(unsigned int status) {
  unsigned int result = 0;
  if (status & fp::invalid) result |= FP_TRAP_INVALID_OPERATION;
  if (status & fp::overflow) result |= FP_TRAP_OVERFLOW;
  if (status & fp::underflow) result |= FP_TRAP_UNDERFLOW;
  if (status & fp::divide_by_zero) result |= FP_TRAP_ZERO_DIVIDE;
  if (status & fp::inexact) result |= FP_TRAP_INEXACT;
  return result;
}

// NetBSD's native VAX arithmetic traps report their cause through siginfo,
// independently of the VM's software IEEE flags (vax/vax/trap.c).
inline unsigned int vax_fpe_flags(int code) {
  switch (code) {
    case FPE_FLTINV: case FPE_FLTSUB: return FP_TRAP_INVALID_OPERATION;
    case FPE_FLTOVF: return FP_TRAP_OVERFLOW;
    case FPE_FLTUND: return FP_TRAP_UNDERFLOW;
    case FPE_FLTDIV: return FP_TRAP_ZERO_DIVIDE;
    case FPE_FLTRES: return FP_TRAP_INEXACT;
    default: return 0;
  }
}

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

}
