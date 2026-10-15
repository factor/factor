// Run natively on ARMv7 Linux; validates the kernel's live VFP signal record.
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <csignal>
using cell = uintptr_t;
enum {
  FP_TRAP_INVALID_OPERATION = 1, FP_TRAP_ZERO_DIVIDE = 2,
  FP_TRAP_OVERFLOW = 4, FP_TRAP_UNDERFLOW = 8, FP_TRAP_INEXACT = 16
};
#include "../os-linux-arm.32.hpp"
static volatile sig_atomic_t observed = 0;
static void handler(int, siginfo_t*, void* context) {
  auto fpscr = factor::arm32_signal_fpscr(context);
  assert(fpscr != nullptr);
  assert((factor::uap_fpu_status(context) & 0x1f) == 0x1f);
  assert(factor::fpu_status(*fpscr) == 0x1f);
  factor::uap_clear_fpu_status(context);
  assert((*fpscr & 0x9f) == 0);
  observed = 1;
}
int main() {
  struct sigaction action = {};
  action.sa_sigaction = handler;
  action.sa_flags = SA_SIGINFO;
  sigemptyset(&action.sa_mask);
  assert(sigaction(SIGUSR1, &action, nullptr) == 0);
  unsigned original;
  asm volatile("vmrs %0, fpscr" : "=r"(original));
  unsigned raised = (original & ~0x9fu) | 0x9fu;
  asm volatile("vmsr fpscr, %0" :: "r"(raised));
  assert(raise(SIGUSR1) == 0);
  unsigned restored;
  asm volatile("vmrs %0, fpscr" : "=r"(restored));
  asm volatile("vmsr fpscr, %0" :: "r"(original));
  assert(observed);
  assert((restored & 0x9f) == 0);
  assert((restored & ~0x9fu) == (raised & ~0x9fu));
  ucontext_t empty = {};
  assert(factor::arm32_signal_fpscr(&empty) == nullptr);
  empty.uc_regspace[0] = 0x56465001;
  empty.uc_regspace[1] = 0xffffffff;
  assert(factor::arm32_signal_fpscr(&empty) == nullptr);
  puts("ARM32 live VFP signal context and exception clearing pass");
}
