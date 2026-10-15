// Run on ARMv7 Linux: real sigreturn must interwork in both directions.
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <csignal>
#include <unistd.h>
using cell = uintptr_t;
enum {
  FP_TRAP_INVALID_OPERATION = 1, FP_TRAP_ZERO_DIVIDE = 2,
  FP_TRAP_OVERFLOW = 4, FP_TRAP_UNDERFLOW = 8, FP_TRAP_INEXACT = 16
};
#include "../os-linux-arm.32.hpp"
extern "C" void arm32_fault_arm();
extern "C" void arm32_fault_thumb();
extern "C" void arm32_entry_arm();
extern "C" void arm32_entry_thumb();
static cell fault_entry, handler_entry;
static volatile sig_atomic_t observed;
static void handler(int, siginfo_t*, void* context) {
  auto& regs = ((ucontext_t*)context)->uc_mcontext;
  // A second illegal instruction at the destination proves failed interworking.
  if (regs.arm_pc != (fault_entry & ~cell(1))) _exit(32);
  assert((regs.arm_cpsr & 32) == ((fault_entry & 1) << 5));
#ifdef OLD_REDIRECT
  regs.arm_pc = handler_entry;
#else
  factor::arm32_signal_set_entry(context, handler_entry);
#endif
  ++observed;
}
int main() {
  struct sigaction action = {};
  action.sa_sigaction = handler;
  action.sa_flags = SA_SIGINFO;
  sigemptyset(&action.sa_mask);
  assert(sigaction(SIGILL, &action, nullptr) == 0);
  void (*faults[])() = {arm32_fault_arm, arm32_fault_thumb};
  void (*entries[])() = {arm32_entry_arm, arm32_entry_thumb};
  for (auto fault : faults) {
    for (auto entry : entries) {
      fault_entry = (cell)fault;
      handler_entry = (cell)entry;
      auto before = observed;
      fault();
      assert(observed == before + 1);
    }
  }
  puts("ARM32 kernel signal ARM/Thumb entry combinations pass");
}
