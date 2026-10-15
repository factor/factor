// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
#include "os-linux-sparc-context.hpp"
namespace factor {
inline static void flush_icache(cell start, cell length) {
  __builtin___clear_cache((char*)start, (char*)(start + length));
}
#define UAP_STACK_POINTER(raw) sparc_signal_sp(raw)
#define UAP_PROGRAM_COUNTER(raw) sparc_signal_pc(raw)

inline unsigned long* sparc_signal_fsr(void* raw) {
#ifdef FACTOR_64
  auto* saved = static_cast<struct sigcontext*>(raw)->sigc_fpu_save;
  return saved ? &saved->si_fsr : nullptr;
#else
  // rt frame starts at pt_regs; two 32-bit mask words follow its 20 words.
  uint32_t* regs = static_cast<uint32_t*>(raw);
  uint32_t* saved = (uint32_t*)(cell)regs[22];
  // Compat frames from a 64-bit kernel store a 64-bit FSR after 64 FP words.
  // Select its low word on this big-endian ABI and preserve the upper word.
  size_t offset = (regs[0] & 0xff000000U) == 0xff000000U ? 65 : 32;
  return saved ? reinterpret_cast<unsigned long*>(saved + offset) : nullptr;
#endif
}
inline unsigned int uap_fpu_status(void* raw) {
  unsigned long* fsr = sparc_signal_fsr(raw);
  return fsr ? (unsigned int)*fsr : 0;
}
inline void uap_clear_fpu_status(void* raw) {
  unsigned long* fsr = sparc_signal_fsr(raw);
  if (fsr) *fsr &= ~0x3ffUL;
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
inline unsigned int signal_fpu_status(unsigned int status, int code) {
  unsigned int traps = fpu_status(status);
  // Linux also identifies the enabled exception in siginfo. Preserve it
  // when the saved FSR is absent or uses a different compatibility layout.
  switch (code) {
    case FPE_FLTINV: return traps | FP_TRAP_INVALID_OPERATION;
    case FPE_FLTDIV: return traps | FP_TRAP_ZERO_DIVIDE;
    case FPE_FLTOVF: return traps | FP_TRAP_OVERFLOW;
    case FPE_FLTUND: return traps | FP_TRAP_UNDERFLOW;
    case FPE_FLTRES: return traps | FP_TRAP_INEXACT;
    default: return traps;
  }
}
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}
