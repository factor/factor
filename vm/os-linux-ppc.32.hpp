#include <ucontext.h>

namespace factor {

#define FRAME_RETURN_ADDRESS(frame, vm) \
  *((void**)(vm->frame_successor(frame) + 1) + 1)
#define UAP_STACK_POINTER(ucontext) \
  ((ucontext_t*)ucontext)->uc_mcontext.uc_regs->gregs[1]
#define UAP_PROGRAM_COUNTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.uc_regs->gregs[32])
#define UAP_SET_TOC_POINTER(uap, ptr) (void) 0

#define CODE_TO_FUNCTION_POINTER(code) (void) 0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void) 0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

#define UAP_STACK_POINTER_TYPE unsigned long

inline static unsigned int uap_fpu_status(void* uap) {
  union {
    double as_double;
    unsigned int as_uint[2];
  } tmp;
  tmp.as_double = ((ucontext_t*)uap)->uc_mcontext.uc_regs->fpregs.fpscr;
  return tmp.as_uint[1];
}

inline static void uap_clear_fpu_status(void* uap) {
  union {
    double as_double;
    unsigned int as_uint[2];
  } tmp;
  tmp.as_double = ((ucontext_t*)uap)->uc_mcontext.uc_regs->fpregs.fpscr;
  tmp.as_uint[1] &= 0x0007f8ff;
  ((ucontext_t*)uap)->uc_mcontext.uc_regs->fpregs.fpscr = tmp.as_double;
}

}
