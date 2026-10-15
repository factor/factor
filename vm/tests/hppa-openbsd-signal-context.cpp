// Run with hppa-openbsd-signal-context.S on native OpenBSD/hppa.
#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <sys/mman.h>
#include <unistd.h>
namespace factor {
using cell = uintptr_t;
enum {
  FP_TRAP_INVALID_OPERATION = 1, FP_TRAP_OVERFLOW = 2,
  FP_TRAP_UNDERFLOW = 4, FP_TRAP_ZERO_DIVIDE = 8, FP_TRAP_INEXACT = 16
};
}
#include "../os-openbsd-hppa.hpp"

extern "C" void hppa_signal_register_fault(void*, unsigned long*);
static volatile sig_atomic_t caught, valid;
static void handler(int number, siginfo_t* info, void* context) {
  caught++;
  valid = number == SIGSEGV && info && info->si_signo == SIGSEGV &&
      UAP_STACK_POINTER(context) == 0x12345678UL &&
      UAP_GLOBAL_POINTER(context) == 0x23456789UL;
  if (valid) {
    UAP_STACK_POINTER(context) = 0x3456789aUL;
    UAP_GLOBAL_POINTER(context) = 0x456789abUL;
  }
  // Resume immediately after the single faulting load in the assembly probe.
  UAP_PROGRAM_COUNTER(context) = UAP_NEXT_PROGRAM_COUNTER(context);
  UAP_NEXT_PROGRAM_COUNTER(context) += 4;
}

int main() {
  size_t length = getpagesize();
  void* guard = mmap(nullptr, length, PROT_NONE, MAP_PRIVATE | MAP_ANON, -1, 0);
  if (guard == MAP_FAILED) return 2;
  struct sigaction action = {};
  action.sa_sigaction = handler;
  action.sa_flags = SA_SIGINFO;
  sigemptyset(&action.sa_mask);
  if (sigaction(SIGSEGV, &action, nullptr)) return 3;
  unsigned long restored[2] = {};
  hppa_signal_register_fault(guard, restored);
  munmap(guard, length);
  bool pass = caught == 1 && valid && restored[0] == 0x3456789aUL &&
      restored[1] == 0x456789abUL;
  printf("OpenBSD HPPA native R18/R19 signal read/write %s: %lx %lx\n",
      pass ? "PASS" : "FAIL", restored[0], restored[1]);
  return pass ? 0 : 1;
}
