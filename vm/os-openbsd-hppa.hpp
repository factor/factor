#include "hppa-cache.hpp"
#include <signal.h>
namespace factor {
inline static void flush_icache(cell start, cell length) {
  hppa_flush_icache(start, length);
}
// OpenBSD saves the trapframe order, rather than indexing sc_regs by GPR.
// Its first five slots are r22, r21, r30, r20 and SAR; r18/r19 are 22/23.
#define UAP_STACK_POINTER(raw) (((struct sigcontext*)(raw))->sc_regs[22])
#define UAP_PROGRAM_COUNTER(raw) (((struct sigcontext*)(raw))->sc_pcoqh)
#define UAP_NEXT_PROGRAM_COUNTER(raw) (((struct sigcontext*)(raw))->sc_pcoqt)
#define UAP_GLOBAL_POINTER(raw) (((struct sigcontext*)(raw))->sc_regs[23])
inline static unsigned int uap_fpu_status(void* raw) {
  return ((struct sigcontext*)raw)->sc_fpregs[0];
}
inline static void uap_clear_fpu_status(void* raw) {
  ((struct sigcontext*)raw)->sc_fpregs[0] &= ~0xf8000000UL;
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
#undef FUNCTION_CODE_POINTER
#undef FUNCTION_TOC_POINTER
#define FUNCTION_CODE_POINTER(ptr) hppa_function_field((uintptr_t)(ptr), 0)
#define FUNCTION_TOC_POINTER(ptr) hppa_function_field((uintptr_t)(ptr), 1)
}
