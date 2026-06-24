#include "atomic-cl-64.hpp"

namespace factor {

#define ESP Sp
#define EIP Pc

inline static void flush_icache(cell start, cell len) {
  HANDLE proc = GetCurrentProcess();
  FlushInstructionCache(proc, (LPCVOID)start, len);
}

inline static unsigned int fpu_status(unsigned int status) {
  unsigned int r = 0;

  if (status & 0x01)
    r |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x02)
    r |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x04)
    r |= FP_TRAP_OVERFLOW;
  if (status & 0x08)
    r |= FP_TRAP_UNDERFLOW;
  if (status & 0x10)
    r |= FP_TRAP_INEXACT;

  return r;
}

}
