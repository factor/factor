#include <signal.h>

namespace factor {
inline static unsigned int uap_fpu_status(void* uap) {
  const fpu_state& fpu = static_cast<ucontext_t*>(uap)->uc_mcontext.fpu.fp_fxsave;
  return fpu.status | fpu.mxcsr;
}

inline static void uap_clear_fpu_status(void* uap) {
  fpu_state& fpu = static_cast<ucontext_t*>(uap)->uc_mcontext.fpu.fp_fxsave;
  fpu.status = 0;
  fpu.mxcsr &= 0xffffffc0;
}

#define UAP_STACK_POINTER(uap) (static_cast<ucontext_t*>(uap)->uc_mcontext.rsp)
#define UAP_PROGRAM_COUNTER(uap) (static_cast<ucontext_t*>(uap)->uc_mcontext.rip)
#define UAP_SET_TOC_POINTER(uap, ptr) (void)0
#define UAP_STACK_POINTER_TYPE unsigned long

static const unsigned JIT_FRAME_SIZE = 32;
}
