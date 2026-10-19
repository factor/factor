// Run natively on Haiku ARM64; validates the kernel's saved FP signal state.
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <csignal>
using cell = uintptr_t;
enum {
  FP_TRAP_INVALID_OPERATION = 1, FP_TRAP_ZERO_DIVIDE = 2,
  FP_TRAP_OVERFLOW = 4, FP_TRAP_UNDERFLOW = 8, FP_TRAP_INEXACT = 16
};
#include "../os-haiku-arm.64.hpp"

static volatile sig_atomic_t observed = 0;

static void handler(int, siginfo_t*, void* context) {
  assert(UAP_PROGRAM_COUNTER(context) != 0);
  assert(UAP_STACK_POINTER(context) != 0);
  assert((factor::uap_fpu_status(context) & 0x1f) == 0x1f);
  assert(factor::fpu_status(factor::uap_fpu_status(context)) == 0x1f);
  factor::uap_clear_fpu_status(context);
  assert(factor::uap_fpu_status(context) == 0);
  observed = 1;
}

int main() {
  struct sigaction action = {};
  action.sa_sigaction = handler;
  action.sa_flags = SA_SIGINFO;
  sigemptyset(&action.sa_mask);
  assert(sigaction(SIGUSR1, &action, nullptr) == 0);

  unsigned long original;
  asm volatile("mrs %0, fpsr" : "=r"(original));
  unsigned long raised = (original & ~0x1ful) | 0x1ful;
  asm volatile("msr fpsr, %0" :: "r"(raised));
  assert(raise(SIGUSR1) == 0);
  unsigned long restored;
  asm volatile("mrs %0, fpsr" : "=r"(restored));
  asm volatile("msr fpsr, %0" :: "r"(original));

  assert(observed);
  assert((restored & 0x1f) == 0);
  assert((restored & ~0x1ful) == (raised & ~0x1ful));
  puts("Haiku ARM64 live FP signal context: PASS");
}
