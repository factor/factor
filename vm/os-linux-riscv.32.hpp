#include <signal.h>
#include <sys/cachectl.h>
namespace factor {
inline static void flush_icache(cell start, cell len) {
  if (__riscv_flush_icache((void*)start, (void*)(start + len), 0)) abort();
}
#define UAP_STACK_POINTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.__gregs[2])
#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.__gregs[0])
inline static unsigned int uap_fpu_status(void* uap) {
  return ((ucontext_t*)uap)->uc_mcontext.__fpregs.__d.__fcsr;
}
inline static void uap_clear_fpu_status(void* uap) {
  ((ucontext_t*)uap)->uc_mcontext.__fpregs.__d.__fcsr &= ~0x1f;
}
inline static unsigned int fpu_status(unsigned int status) {
  unsigned int r = 0;
  if (status & 0x10) r |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x08) r |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x04) r |= FP_TRAP_OVERFLOW;
  if (status & 0x02) r |= FP_TRAP_UNDERFLOW;
  if (status & 0x01) r |= FP_TRAP_INEXACT;
  return r;
}
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}
