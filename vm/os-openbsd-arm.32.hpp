#include <signal.h>
#include <machine/sysarch.h>

namespace factor {
inline static void flush_icache(cell start, cell len) {
  struct arm_sync_icache_args args = {(unsigned int)start, len};
  if (sysarch(ARM_SYNC_ICACHE, &args) != 0) abort();
}
#define UAP_STACK_POINTER(uap) (((struct sigcontext*)uap)->sc_usr_sp)
#define UAP_PROGRAM_COUNTER(uap) (((struct sigcontext*)uap)->sc_pc)
inline static unsigned int uap_fpu_status(void* uap) {
  auto context = (struct sigcontext*)uap;
  return context->sc_fpused ? context->sc_fpscr : 0;
}
inline static void uap_clear_fpu_status(void* uap) {
  auto context = (struct sigcontext*)uap;
  if (context->sc_fpused) context->sc_fpscr &= ~0x9fu;
}
inline static unsigned int fpu_status(unsigned int status) {
  unsigned int result = 0;
  if (status & 1) result |= FP_TRAP_INVALID_OPERATION;
  if (status & 2) result |= FP_TRAP_ZERO_DIVIDE;
  if (status & 4) result |= FP_TRAP_OVERFLOW;
  if (status & 8) result |= FP_TRAP_UNDERFLOW;
  if (status & 16) result |= FP_TRAP_INEXACT;
  return result;
}
}
