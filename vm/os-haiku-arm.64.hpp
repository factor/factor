#pragma once
#include <signal.h>

namespace factor {

inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char*)start, (char*)(start + len));
}

#define UAP_STACK_POINTER(uap) (((ucontext_t*)uap)->uc_mcontext.sp)
#define UAP_PROGRAM_COUNTER(uap) (((ucontext_t*)uap)->uc_mcontext.elr)

inline static unsigned int uap_fpu_status(void* uap) {
  return ((ucontext_t*)uap)->uc_mcontext.fpsr;
}

inline static void uap_clear_fpu_status(void* uap) {
  ((ucontext_t*)uap)->uc_mcontext.fpsr = 0;
}

inline static unsigned int fpu_status(unsigned int status) {
  unsigned int result = 0;
  if (status & 0x01) result |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x02) result |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x04) result |= FP_TRAP_OVERFLOW;
  if (status & 0x08) result |= FP_TRAP_UNDERFLOW;
  if (status & 0x10) result |= FP_TRAP_INEXACT;
  return result;
}

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

}
