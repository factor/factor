#include <signal.h>
namespace factor {
inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char*)start, (char*)(start + len));
}
#define UAP_STACK_POINTER(uap) (((struct sigcontext*)uap)->sc_sp)
#define UAP_PROGRAM_COUNTER(uap) (((struct sigcontext*)uap)->sc_elr)
// OpenBSD arm64 does not currently put FP state in sigcontext.
inline static unsigned int uap_fpu_status(void*) {
  unsigned long status; asm volatile("mrs %0, fpsr" : "=r"(status)); return status;
}
inline static void uap_clear_fpu_status(void*) { asm volatile("msr fpsr, xzr"); }
inline static unsigned int fpu_status(unsigned int status) {
  unsigned int r = 0;

  if (status & 0x01)
    r |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x02)
    r |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x04)
    r |= FP_TRAP_OVERFLOW;
  if (status & 0x08)
    r |= FP_TRAP_UNDERFLOW;
  if (status & 0x10)
    r |= FP_TRAP_INEXACT;

  return r;
}

}
