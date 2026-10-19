#include <signal.h>
#include <machine/sysarch.h>

namespace factor {
inline static void flush_icache(cell start, cell len) {
  struct riscv_sync_icache_args args = { start, len };
  if (sysarch(RISCV_SYNC_ICACHE, &args) != 0) abort();
}
#define UAP_STACK_POINTER(ucontext) (((struct sigcontext*)ucontext)->sc_sp)
#define UAP_PROGRAM_COUNTER(ucontext) (((struct sigcontext*)ucontext)->sc_sepc)
inline static unsigned int uap_fpu_status(void* uap) {
  return ((struct sigcontext*)uap)->sc_fcsr;
}
inline static void uap_clear_fpu_status(void* uap) {
  ((struct sigcontext*)uap)->sc_fcsr &= ~0x1f;
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
