// Link with ppc64-openbsd-signal-context.S on native OpenBSD/powerpc64.
#include <fenv.h>
#include <stdint.h>
#include <stdio.h>
#include <signal.h>
#include <sys/mman.h>
#include <unistd.h>
#include "../os-openbsd-ppc.64.hpp"

extern "C" void ppc64_signal_register_fault(void*, uintptr_t*);
extern "C" char ppc64_signal_fault_pc[];
static uintptr_t restored[4];
static uint64_t original_fpscr;
static volatile sig_atomic_t caught, valid;

static uint64_t fpscr() {
  uint64_t value;
  __asm__ volatile("mffs 0; stfd 0,0(%0)" : : "r"(&value) : "fr0", "memory");
  return value;
}

static void handler(int number, siginfo_t* info, void* context) {
  caught++;
  valid = number == SIGSEGV && info && info->si_signo == SIGSEGV &&
      UAP_STACK_POINTER(context) == restored[2] &&
      UAP_LINK_REGISTER(context) == restored[3] &&
      UAP_PROGRAM_COUNTER(context) == (uintptr_t)ppc64_signal_fault_pc &&
      UAP_GLOBAL_ENTRY_REGISTER(context) == 0x12345678UL &&
      UAP_TOC_REGISTER(context) == 0x23456789UL &&
      factor::uap_fpu_status(context) == (unsigned int)original_fpscr;
  if (valid) {
    UAP_GLOBAL_ENTRY_REGISTER(context) = 0x3456789aUL;
    UAP_TOC_REGISTER(context) = 0x456789abUL;
    factor::uap_clear_fpu_status(context);
  }
  UAP_PROGRAM_COUNTER(context) += 4;
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
  fenv_t previous;
  if (fegetenv(&previous) || fesetround(FE_DOWNWARD) ||
      feraiseexcept(FE_INVALID | FE_INEXACT)) return 4;
  original_fpscr = fpscr();
  ppc64_signal_register_fault(guard, restored);
  uint64_t after = fpscr();
  fesetenv(&previous);
  munmap(guard, length);
  bool pass = caught == 1 && valid && restored[0] == 0x3456789aUL &&
      restored[1] == 0x456789abUL &&
      (unsigned int)after == ((unsigned int)original_fpscr & 0x0007f8ffU);
  printf("OpenBSD PPC64 native SP/LR/R12/TOC/FPSCR signal read/write %s\n",
      pass ? "PASS" : "FAIL");
  return pass ? 0 : 1;
}
