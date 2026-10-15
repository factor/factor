// Copyright (C) 2026 Doug Coleman. BSD license.
#include <ucontext.h>
namespace factor {
#define UAP_STACK_POINTER(raw) (((ucontext_t*)(raw))->uc_mcontext.__gregs[_REG_O6])
#define UAP_PROGRAM_COUNTER(raw) (((ucontext_t*)(raw))->uc_mcontext.__gregs[_REG_PC])
inline auto& sparc_signal_sp(void* raw) { return UAP_STACK_POINTER(raw); }
inline auto& sparc_signal_pc(void* raw) { return UAP_PROGRAM_COUNTER(raw); }
inline auto& sparc_signal_npc(void* raw) {
  return ((ucontext_t*)raw)->uc_mcontext.__gregs[_REG_nPC];
}
inline cell sparc_signal_stack_address(void* raw) {
  return _UC_MACHINE_SP((ucontext_t*)raw);
}
inline void sparc_redirect_signal(void* raw, cell target) {
  _UC_MACHINE_SET_PC((ucontext_t*)raw, target);
}
inline void flush_icache(cell start, cell length) {
  __builtin___clear_cache((char*)start, (char*)(start + length));
}
inline unsigned int uap_fpu_status(void* raw) {
#if __SIZEOF_POINTER__ == 4
  (void)raw;
  unsigned long fsr;
  __asm__ volatile("st %%fsr, %0" : "=m"(fsr));
  return fsr;
#else
  auto* uc = (ucontext_t*)raw;
  return (uc->uc_flags & _UC_FPU) ? uc->uc_mcontext.__fpregs.__fpu_fsr : 0;
#endif
}
inline void uap_clear_fpu_status(void* raw) {
#if __SIZEOF_POINTER__ == 4
  (void)raw;
  unsigned long fsr;
  __asm__ volatile("st %%fsr, %0" : "=m"(fsr));
  fsr &= ~0x3ffUL;
  __asm__ volatile("ld %0, %%fsr" : : "m"(fsr));
#else
  auto* uc = (ucontext_t*)raw;
  if (uc->uc_flags & _UC_FPU) uc->uc_mcontext.__fpregs.__fpu_fsr &= ~0x3ffUL;
#endif
}
inline unsigned int fpu_status(unsigned int status) {
  unsigned int result = 0;
  if (status & 0x10) result |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x08) result |= FP_TRAP_OVERFLOW;
  if (status & 0x04) result |= FP_TRAP_UNDERFLOW;
  if (status & 0x02) result |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x01) result |= FP_TRAP_INEXACT;
  return result;
}
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}
