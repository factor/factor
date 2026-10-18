#pragma once
#include <signal.h>

namespace factor {
inline static unsigned int signal_fpu_status(unsigned int status, int code) {
  unsigned int traps = fpu_status(status);
  // An enabled exception need not set sticky flags in the saved context.
  switch (code) {
    case FPE_FLTINV: return traps | FP_TRAP_INVALID_OPERATION;
    case FPE_FLTDIV: return traps | FP_TRAP_ZERO_DIVIDE;
    case FPE_FLTOVF: return traps | FP_TRAP_OVERFLOW;
    case FPE_FLTUND: return traps | FP_TRAP_UNDERFLOW;
    case FPE_FLTRES: return traps | FP_TRAP_INEXACT;
    default: return traps;
  }
}
}
