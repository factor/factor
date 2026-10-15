#include <signal.h>
#include <ucontext.h>
#include <mips/cachectl.h>

namespace factor {
// NetBSD O32 context registers have the native pointer width.
inline static cell& mips_netbsd_context_cell(void* slot) {
  return *(cell*)slot;
}
#define UAP_STACK_POINTER(uap) factor::mips_netbsd_context_cell(&((ucontext_t*)(uap))->uc_mcontext.__gregs[_REG_SP])
#define UAP_PROGRAM_COUNTER(uap) factor::mips_netbsd_context_cell(&((ucontext_t*)(uap))->uc_mcontext.__gregs[_REG_EPC])
#define UAP_NATIVE_ENTRY(uap, entry) \
  factor::mips_netbsd_context_cell(&((ucontext_t*)(uap))->uc_mcontext.__gregs[_REG_T9]) = (entry)
inline static void flush_icache(cell start, cell len) {
  (void)_cacheflush((void*)start, len, BCACHE);
}
inline static unsigned int uap_fpu_status(void* uap) {
  return ((ucontext_t*)uap)->uc_mcontext.__fpregs.__fp_csr;
}
inline static void uap_clear_fpu_status(void* uap) {
  const unsigned int clear = ~((0x1fu << 2) | (0x3fu << 12));
  ((ucontext_t*)uap)->uc_mcontext.__fpregs.__fp_csr &= clear;
  unsigned int live;
  __asm__ volatile(".set push\n\t.set hardfloat\n\tcfc1 %0,$31\n\tnop\n\t.set pop" : "=r"(live));
  live &= clear;
  __asm__ volatile(".set push\n\t.set hardfloat\n\tctc1 %0,$31\n\tnop\n\tnop\n\tnop\n\t.set pop"
                   : : "r"(live) : "memory");
}
inline static unsigned int fpu_status(unsigned int status) {
  const unsigned int bits = ((status >> 2) | (status >> 12)) & 0x1f;
  unsigned int r = 0;
  if (bits & 0x10) r |= FP_TRAP_INVALID_OPERATION;
  if (bits & 0x08) r |= FP_TRAP_ZERO_DIVIDE;
  if (bits & 0x04) r |= FP_TRAP_OVERFLOW;
  if (bits & 0x02) r |= FP_TRAP_UNDERFLOW;
  if (bits & 0x01) r |= FP_TRAP_INEXACT;
  return r;
}
// The NetBSD MIPS trap entry clears live FCSR causes before saving ucontext.
// siginfo.si_trap retains the original complete FCSR, including all causes.
inline static unsigned int signal_fpu_status(unsigned int status, unsigned int trap) {
  return fpu_status(trap ? trap : status);
}
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}
