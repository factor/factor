#include <ucontext.h>

namespace factor {

inline static unsigned int uap_fpu_status(void* uap) {
  ucontext_t* ucontext = (ucontext_t*)uap;
  return ucontext->uc_mcontext.fpregs->swd |
         ucontext->uc_mcontext.fpregs->mxcsr;
}

inline static void uap_clear_fpu_status(void* uap) {
  ucontext_t* ucontext = (ucontext_t*)uap;
  ucontext->uc_mcontext.fpregs->swd = 0;
  ucontext->uc_mcontext.fpregs->mxcsr &= 0xffffffc0;
}

#define UAP_STACK_POINTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.gregs[15])
#define UAP_PROGRAM_COUNTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.gregs[16])
#define UAP_SET_TOC_POINTER(uap, ptr) (void)0

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

#define UAP_STACK_POINTER_TYPE greg_t

/* Must match the leaf-stack-frame-size, signal-handler-stack-frame-size,
and stack-frame-size constants in bootstrap/assembler/x86.64.unix.factor */
static const unsigned LEAF_FRAME_SIZE = 16;
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 160;
static const unsigned JIT_FRAME_SIZE = 32;

}
