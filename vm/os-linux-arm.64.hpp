#include <ucontext.h>
#include <asm/unistd.h>
#include <sys/syscall.h>

namespace factor {

#define CALLSTACK_BOTTOM(ctx) \
  (ctx->callstack_seg->end - sizeof(cell) * 6)

#define UAP_STACK_POINTER(ucontext) \
  (static_cast<ucontext_t*>(ucontext)->uc_mcontext.sp)
#define UAP_PROGRAM_COUNTER(ucontext) \
  (static_cast<ucontext_t*>(ucontext)->uc_mcontext.pc)

inline static unsigned int uap_fpu_status(void* uap) {
  (void)uap;
  return 0;
}

inline static void uap_clear_fpu_status(void* uap) {
  (void)uap;
}

inline static unsigned int fpu_status(unsigned int status) {
  unsigned int r = 0;

  if (status & 0x01)
    r |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x04)
    r |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x08)
    r |= FP_TRAP_OVERFLOW;
  if (status & 0x10)
    r |= FP_TRAP_UNDERFLOW;
  if (status & 0x20)
    r |= FP_TRAP_INEXACT;

  return r;
}

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

}
