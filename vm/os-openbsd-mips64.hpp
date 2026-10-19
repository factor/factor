#include <signal.h>
#include <limits.h>
#include <machine/sysarch.h>

namespace factor {
static_assert(sizeof(((struct sigcontext*)0)->sc_regs[0]) == sizeof(cell),
              "OpenBSD MIPS64 signal registers must match the N64 cell");
#define UAP_STACK_POINTER(uap) (((struct sigcontext*)(uap))->sc_regs[29])
#define UAP_PROGRAM_COUNTER(uap) (((struct sigcontext*)(uap))->sc_pc)
#define UAP_NATIVE_ENTRY(uap, entry) \
  (((struct sigcontext*)(uap))->sc_regs[25] = (entry))

inline static void flush_icache(cell start, cell len) {
  // libc's cacheflush length is int even though the address space is N64.
  while (len) {
    const int chunk = len > (cell)INT_MAX ? INT_MAX : (int)len;
    (void)cacheflush((void*)start, chunk, BCACHE);
    start += chunk;
    len -= chunk;
  }
}
inline static unsigned int uap_fpu_status(void* uap) {
  const struct sigcontext* saved = (struct sigcontext*)uap;
  return saved->sc_fpused ? (unsigned int)saved->sc_fpregs[32] : 0;
}
inline static void uap_clear_fpu_status(void* uap) {
  struct sigcontext* saved = (struct sigcontext*)uap;
  const unsigned int clear = ~((0x1fu << 2) | (0x3fu << 12));
  if (saved->sc_fpused)
    saved->sc_fpregs[32] &= ~(cell)((0x1fu << 2) | (0x3fu << 12));
  unsigned int live;
  __asm__ volatile("cfc1 %0,$31\n\tnop" : "=r"(live));
  live &= clear;
  __asm__ volatile("ctc1 %0,$31\n\tnop\n\tnop\n\tnop"
                   : : "r"(live) : "memory");
}
inline static unsigned int fpu_status(unsigned int status) {
  const unsigned int bits = ((status >> 2) | (status >> 12)) & 0x1f;
  unsigned int result = 0;
  if (bits & 0x10) result |= FP_TRAP_INVALID_OPERATION;
  if (bits & 0x08) result |= FP_TRAP_ZERO_DIVIDE;
  if (bits & 0x04) result |= FP_TRAP_OVERFLOW;
  if (bits & 0x02) result |= FP_TRAP_UNDERFLOW;
  if (bits & 0x01) result |= FP_TRAP_INEXACT;
  return result;
}
}
