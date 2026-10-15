#include <signal.h>
#include <ucontext.h>
#include "netbsd-alpha-signal-fpu.hpp"
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
#define UAP_STACK_POINTER(raw) (((ucontext_t*)raw)->uc_mcontext.__gregs[_REG_SP])
#define UAP_PROGRAM_COUNTER(raw) (((ucontext_t*)raw)->uc_mcontext.__gregs[_REG_PC])
#define UAP_NATIVE_ENTRY(raw, entry) \
  (((ucontext_t*)raw)->uc_mcontext.__gregs[_REG_T12] = (entry))
inline static unsigned int uap_fpu_status(void* raw) {
  // NetBSD signal contexts store software FP_C, not raw hardware FPCR.
  return (((ucontext_t*)raw)->uc_mcontext.__fpregs.__fp_fpcr >> 17) & 63;
}
inline static void uap_clear_fpu_status(void* raw) {
  ((ucontext_t*)raw)->uc_mcontext.__fpregs.__fp_fpcr &= ~(UINT64_C(63) << 17);
}
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}
