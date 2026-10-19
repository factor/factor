#include <ucontext.h>

namespace factor {

#define UAP_LINK_REGISTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.__gregs[_REG_LR])

#define UAP_STACK_POINTER(uap) _UC_MACHINE_SP((ucontext_t*)uap)
#define UAP_PROGRAM_COUNTER(uap) _UC_MACHINE_PC((ucontext_t*)uap)

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

inline static unsigned int uap_fpu_status(void* uap) {
  return ((ucontext_t*)uap)->uc_mcontext.__fpregs.__fpu_fpscr;
}

inline static void uap_clear_fpu_status(void* uap) {
  ((ucontext_t*)uap)->uc_mcontext.__fpregs.__fpu_fpscr &= 0x0007f8ff;
}

}
