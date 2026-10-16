#include <signal.h>

namespace factor {
inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char*)start, (char*)(start + len));
}
#define UAP_STACK_POINTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.__gprs[1])
#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.__pc)
inline static unsigned int uap_fpu_status(void* uap) {
  return ((ucontext_t*)uap)->uc_mcontext.__fpcsr;
}
inline static void uap_clear_fpu_status(void* uap) {
  ((ucontext_t*)uap)->uc_mcontext.__fpcsr &= ~0xb18;
}
inline static unsigned int fpu_status(unsigned int status) {
  unsigned int r = 0;
  if (status & 0x100) r |= FP_TRAP_INEXACT;
  if (status & 0x10) r |= FP_TRAP_UNDERFLOW;
  if (status & 0x08) r |= FP_TRAP_OVERFLOW;
  if (status & 0x800) r |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x200) r |= FP_TRAP_INVALID_OPERATION;
  return r;
}
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}
