#include <signal.h>
#include <ucontext.h>

namespace factor {

inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char*)start, (char*)(start + len));
}

#define UAP_STACK_POINTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.mc_gpregs.gp_sp)
#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.mc_gpregs.gp_elr)

inline static unsigned int uap_fpu_status(void* uap) {
  mcontext_t& context = ((ucontext_t*)uap)->uc_mcontext;
  return (context.mc_flags & _MC_FP_VALID) ? context.mc_fpregs.fp_sr : 0;
}

inline static void uap_clear_fpu_status(void* uap) {
  mcontext_t& context = ((ucontext_t*)uap)->uc_mcontext;
  if (context.mc_flags & _MC_FP_VALID)
    context.mc_fpregs.fp_sr = 0;
}

inline static unsigned int fpu_status(unsigned int status) {
  unsigned int r = 0;

  if (status & 0x01)
    r |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x02)
    r |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x04)
    r |= FP_TRAP_OVERFLOW;
  if (status & 0x08)
    r |= FP_TRAP_UNDERFLOW;
  if (status & 0x10)
    r |= FP_TRAP_INEXACT;

  return r;
}

}
