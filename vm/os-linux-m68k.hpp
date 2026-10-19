#include <ucontext.h>
namespace factor {
inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char*)start, (char*)(start + len));
}
#define UAP_STACK_POINTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.gregs[R_SP])
#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.gregs[R_PC])
inline static unsigned int uap_fpu_status(void* uap) {
  return ((ucontext_t*)uap)->uc_mcontext.fpregs.f_psr;
}
inline static void uap_clear_fpu_status(void* uap) {
  // Clear current and accrued exceptions, retaining conditions and quotient.
  ((ucontext_t*)uap)->uc_mcontext.fpregs.f_psr &= ~0xfff8;
}
inline static unsigned int fpu_status(unsigned int status) {
  // A hardware trap can report current status before its flag is accrued.
  unsigned int result = 0;
  if (status & 0xe080) result |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x1040) result |= FP_TRAP_OVERFLOW;
  if (status & 0x0820) result |= FP_TRAP_UNDERFLOW;
  if (status & 0x0410) result |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x0308) result |= FP_TRAP_INEXACT;
  return result;
}
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}
