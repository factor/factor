#include <ucontext.h>

namespace factor {

#define UAP_LINK_REGISTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.mc_lr)

#define UAP_STACK_POINTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.mc_gpr[1])
#define UAP_PROGRAM_COUNTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.mc_srr0)
#define UAP_GLOBAL_ENTRY_REGISTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.mc_gpr[12])
#define UAP_TOC_REGISTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.mc_gpr[2])

inline static unsigned int uap_fpu_status(void* uap) {
  return (unsigned int)((ucontext_t*)uap)->uc_mcontext.mc_fpscr;
}

inline static void uap_clear_fpu_status(void* uap) {
  ((ucontext_t*)uap)->uc_mcontext.mc_fpscr &= UINT64_C(0xffffffff0007f8ff);
}

}
