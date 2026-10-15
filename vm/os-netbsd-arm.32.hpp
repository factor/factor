#pragma once
#include "os-netbsd.hpp"

namespace factor {
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
#define UAP_STACK_POINTER(uap) (((ucontext_t*)uap)->uc_mcontext.__gregs[_REG_SP])
#define UAP_PROGRAM_COUNTER(uap) (((ucontext_t*)uap)->uc_mcontext.__gregs[_REG_PC])
inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char*)start, (char*)(start + len));
}
inline static unsigned int uap_fpu_status(void* uap) {
  auto uc = (ucontext_t*)uap;
  return (uc->uc_flags & _UC_ARM_VFP) ? uc->uc_mcontext.__fpu.__vfpregs.__vfp_fpscr : 0;
}
inline static void uap_clear_fpu_status(void* uap) {
  auto uc = (ucontext_t*)uap;
  if (uc->uc_flags & _UC_ARM_VFP) uc->uc_mcontext.__fpu.__vfpregs.__vfp_fpscr &= ~0x9fu;
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
