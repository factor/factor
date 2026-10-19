#include <signal.h>
namespace factor {
inline static void flush_icache(cell start, cell len) {
  (void)start; (void)len;
  __asm__ __volatile__("mb; call_pal 0x86" ::: "memory");
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
#define UAP_STACK_POINTER(raw) (((struct sigcontext*)raw)->sc_regs[30])
#define UAP_PROGRAM_COUNTER(raw) (((struct sigcontext*)raw)->sc_pc)
#define UAP_NATIVE_ENTRY(raw, entry) \
  (((struct sigcontext*)raw)->sc_regs[27] = (entry))
inline static unsigned int uap_fpu_status(void* raw) {
  return (((struct sigcontext*)raw)->sc_fpcr >> 52) | (((struct sigcontext*)raw)->sc_fp_control >> 17);
}
inline static void uap_clear_fpu_status(void* raw) {
  ((struct sigcontext*)raw)->sc_fpcr &= ~((UINT64_C(63) << 52) | (UINT64_C(1) << 63));
  ((struct sigcontext*)raw)->sc_fp_control &= ~(UINT64_C(63) << 17);
}
}
