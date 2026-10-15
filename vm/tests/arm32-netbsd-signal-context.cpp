// Run natively on ARMv7 NetBSD; validates the kernel's live VFP signal state.
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <csignal>
using cell = uintptr_t;
enum {
  FP_TRAP_INVALID_OPERATION = 1, FP_TRAP_ZERO_DIVIDE = 2,
  FP_TRAP_OVERFLOW = 4, FP_TRAP_UNDERFLOW = 8, FP_TRAP_INEXACT = 16
};
#define FACTOR_ARM32
#include "../os-netbsd-arm.32.hpp"
static volatile sig_atomic_t observed = 0;
static void handler(int, siginfo_t*, void* context) {
  auto uc = (ucontext_t*)context;
  assert(uc->uc_flags & _UC_ARM_VFP);
  auto fpscr = &uc->uc_mcontext.__fpu.__vfpregs.__vfp_fpscr;
  assert(UAP_PROGRAM_COUNTER(context) != 0);
  assert(UAP_STACK_POINTER(context) != 0);
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
  assert(factor::uap_fpu_status(&empty) == 0);
  empty.uc_mcontext.__fpu.__vfpregs.__vfp_fpscr = 0xffffffff;
  factor::uap_clear_fpu_status(&empty);
  assert(empty.uc_mcontext.__fpu.__vfpregs.__vfp_fpscr == 0xffffffff);
  puts("ARM32 live VFP signal context and exception clearing pass");
}
