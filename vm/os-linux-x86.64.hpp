#include <ucontext.h>

namespace factor {

inline static unsigned int uap_fpu_status(void* uap) {
  ucontext_t* ucontext = static_cast<ucontext_t*>(uap);
  return ucontext->uc_mcontext.fpregs->swd |
         ucontext->uc_mcontext.fpregs->mxcsr;
}

inline static void uap_clear_fpu_status(void* uap) {
  ucontext_t* ucontext = static_cast<ucontext_t*>(uap);
  ucontext->uc_mcontext.fpregs->swd = 0;
  ucontext->uc_mcontext.fpregs->mxcsr &= 0xffffffc0;
}

#define UAP_STACK_POINTER(ucontext) \
  ((static_cast<ucontext_t*>(ucontext))->uc_mcontext.gregs[15])
#define UAP_PROGRAM_COUNTER(ucontext) \
  ((static_cast<ucontext_t*>(ucontext))->uc_mcontext.gregs[16])

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

// Must match the stack-frame-size constant in
// bootstrap/assembler/x86.64.unix.factor
static const unsigned JIT_FRAME_SIZE = 32;

}
