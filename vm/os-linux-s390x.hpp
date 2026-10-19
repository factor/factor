#include <signal.h>
#include <ucontext.h>
namespace factor {
// System z has coherent instruction/data caches. A serializing branch
// orders code stores before subsequent instruction fetches on this CPU.
inline static void flush_icache(cell, cell) {
  asm volatile("bcr 15,0" ::: "memory");
}
#define UAP_STACK_POINTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.gregs[15])
#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t*)ucontext)->uc_mcontext.psw.addr)
inline static unsigned int uap_fpu_status(void* uap) {
  return ((ucontext_t*)uap)->uc_mcontext.fpregs.fpc;
}
inline static void uap_clear_fpu_status(void* uap) {
  // Preserve exception masks and rounding mode; clear accrued flags and DXC.
  ((ucontext_t*)uap)->uc_mcontext.fpregs.fpc &= ~0x00f8ff00u;
}
inline static unsigned int fpu_status(unsigned int status) {
  status = s390x_fpc_exceptions(status);
  unsigned int result = 0;
  if (status & 0x00800000) result |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x00400000) result |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x00200000) result |= FP_TRAP_OVERFLOW;
  if (status & 0x00100000) result |= FP_TRAP_UNDERFLOW;
  if (status & 0x00080000) result |= FP_TRAP_INEXACT;
  return result;
}
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}
