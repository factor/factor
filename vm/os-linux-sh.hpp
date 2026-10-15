#include <ucontext.h>
namespace factor {
inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char*)start, (char*)(start + len));
}
#define UAP_STACK_POINTER(uap) (((ucontext_t*)uap)->uc_mcontext.gregs[15])
#define UAP_PROGRAM_COUNTER(uap) (((ucontext_t*)uap)->uc_mcontext.pc)
inline static unsigned int uap_fpu_status(void* uap) {
#if defined(__SH_FPU_ANY__)
  return ((ucontext_t*)uap)->uc_mcontext.fpscr;
#else
  (void)uap;
  return 0;
#endif
}
inline static void uap_clear_fpu_status(void* uap) {
#if defined(__SH_FPU_ANY__)
  // Clear flags and cause bits, preserving enable, precision and register bank.
  ((ucontext_t*)uap)->uc_mcontext.fpscr &= ~0x3f07c;
#else
  (void)uap;
#endif
}
inline static unsigned int fpu_status(unsigned int status) {
  unsigned int result = 0;
  if (status & (1u << 6)) result |= FP_TRAP_INVALID_OPERATION;
  if (status & (1u << 5)) result |= FP_TRAP_ZERO_DIVIDE;
  if (status & (1u << 4)) result |= FP_TRAP_OVERFLOW;
  if (status & (1u << 3)) result |= FP_TRAP_UNDERFLOW;
  if (status & (1u << 2)) result |= FP_TRAP_INEXACT;
  return result;
}
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}
