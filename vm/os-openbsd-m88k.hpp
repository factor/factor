#include <signal.h>
#include <machine/reg.h>
#include <machine/psl.h>
#include <m88k/fpu.h>
extern "C" void factor_m88k_flush_icache(void*, size_t);

namespace factor {
inline static void flush_icache(cell start, cell length) {
  factor_m88k_flush_icache((void*)start, length);
}
inline static struct reg* m88k_signal_registers(void* uap) {
  return (struct reg*)((struct sigcontext*)uap)->sc_regs;
}
#define UAP_STACK_POINTER(uap) (m88k_signal_registers(uap)->r[31])
#define UAP_PROGRAM_COUNTER(uap) (m88k_signal_registers(uap)->sxip & XIP_ADDR)
inline static unsigned int uap_fpu_status(void* uap) {
  return m88k_signal_registers(uap)->fpsr;
}
inline static void uap_clear_fpu_status(void* uap) {
  m88k_signal_registers(uap)->fpsr &= ~0x1f;
}
inline static unsigned int fpu_status(unsigned int status) {
  unsigned int result = 0;
  if (status & FPSR_EFINV) result |= FP_TRAP_INVALID_OPERATION;
  if (status & FPSR_EFDVZ) result |= FP_TRAP_ZERO_DIVIDE;
  if (status & FPSR_EFUNF) result |= FP_TRAP_UNDERFLOW;
  if (status & FPSR_EFOVF) result |= FP_TRAP_OVERFLOW;
  if (status & FPSR_EFINX) result |= FP_TRAP_INEXACT;
  return result;
}
}
