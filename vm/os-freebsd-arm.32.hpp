#include <signal.h>
#include <ucontext.h>

namespace factor {
inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char*)start, (char*)(start + len));
}
#define UAP_STACK_POINTER(uap) (((ucontext_t*)uap)->uc_mcontext.__gregs[_REG_SP])
#define UAP_PROGRAM_COUNTER(uap) (((ucontext_t*)uap)->uc_mcontext.__gregs[_REG_PC])
inline static unsigned int uap_fpu_status(void* uap) {
  auto& context = ((ucontext_t*)uap)->uc_mcontext;
  return context.mc_vfp_ptr && context.mc_vfp_size >= sizeof(mcontext_vfp_t)
      ? ((mcontext_vfp_t*)context.mc_vfp_ptr)->mcv_fpscr : 0;
}
inline static void uap_clear_fpu_status(void* uap) {
  auto& context = ((ucontext_t*)uap)->uc_mcontext;
  if (context.mc_vfp_ptr && context.mc_vfp_size >= sizeof(mcontext_vfp_t))
    ((mcontext_vfp_t*)context.mc_vfp_ptr)->mcv_fpscr &= ~0x9fu;
}
inline static unsigned int fpu_status(unsigned int status) {
  unsigned int result = 0;
  if (status & 1) result |= FP_TRAP_INVALID_OPERATION;
  if (status & 2) result |= FP_TRAP_ZERO_DIVIDE;
  if (status & 4) result |= FP_TRAP_OVERFLOW;
  if (status & 8) result |= FP_TRAP_UNDERFLOW;
  if (status & 16) result |= FP_TRAP_INEXACT;
  return result;
}
}
