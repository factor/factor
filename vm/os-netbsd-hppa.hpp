#include "hppa-cache.hpp"
#include <ucontext.h>
namespace factor {
inline static void flush_icache(cell start, cell length) {
  hppa_flush_icache(start, length);
}
// Factor frames are independent of the upward native r30 stack.
#define UAP_STACK_POINTER(raw) (((ucontext_t*)(raw))->uc_mcontext.__gregs[_REG_R18])
#define UAP_NEXT_PROGRAM_COUNTER(raw) (((ucontext_t*)(raw))->uc_mcontext.__gregs[_REG_PCOQT])
#define UAP_GLOBAL_POINTER(raw) (((ucontext_t*)(raw))->uc_mcontext.__gregs[_REG_R19])
#define UAP_PROGRAM_COUNTER(raw) (((ucontext_t*)(raw))->uc_mcontext.__gregs[_REG_PCOQH])
inline static unsigned int uap_fpu_status(void* raw) {
  return unsigned(((ucontext_t*)raw)->uc_mcontext.__fpregs.__fp_fr.__fp_regs[0] >> 32);
}
inline static void uap_clear_fpu_status(void* raw) {
  ((ucontext_t*)raw)->uc_mcontext.__fpregs.__fp_fr.__fp_regs[0] &= ~UINT64_C(0xf800000000000000);
}
inline static unsigned int fpu_status(unsigned int status) {
  unsigned bits = status >> 27;
  unsigned result = 0;
  if (bits & 16) result |= FP_TRAP_INVALID_OPERATION;
  if (bits & 8) result |= FP_TRAP_ZERO_DIVIDE;
  if (bits & 4) result |= FP_TRAP_OVERFLOW;
  if (bits & 2) result |= FP_TRAP_UNDERFLOW;
  if (bits & 1) result |= FP_TRAP_INEXACT;
  return result;
}
// $$dyncall accepts raw code addresses as well as tagged plabels.
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) hppa_function_field((uintptr_t)(ptr), 0)
#define FUNCTION_TOC_POINTER(ptr) hppa_function_field((uintptr_t)(ptr), 1)
}
