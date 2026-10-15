// Native OpenBSD macppc signal-context/FPSCR probe. The first signal is a
// negative control: resetting only live FPSCR is undone by sigcode.
#include "../os-openbsd-ppc.32.hpp"
#include <stdio.h>

static uint64_t read_fpscr() {
  union { double value; uint64_t bits; } state;
  __asm__ volatile("mffs %0" : "=f"(state.value));
  return state.bits;
}
static void write_fpscr(uint64_t bits) {
  union { double value; uint64_t bits; } state;
  state.bits = bits;
  __asm__ volatile("mtfsf 255,%0" :: "f"(state.value));
}
static volatile sig_atomic_t phase, seen, valid;
static unsigned int expected, saved_before;
static uintptr_t saved_pc, saved_sp;
static void handler(int signal, siginfo_t*, void* context) {
  seen = signal;
  saved_pc = (uintptr_t)UAP_PROGRAM_COUNTER(context);
  saved_sp = (uintptr_t)UAP_STACK_POINTER(context);
  saved_before = factor::uap_fpu_status(context);
  if (saved_before != expected || !saved_pc || !saved_sp) return;
  valid = 1;
  if (phase) factor::uap_clear_fpu_status(context);
  else write_fpscr(read_fpscr() & UINT64_C(0xffffffff0007f8ff));
}
int main() {
  struct sigaction action = {};
  action.sa_sigaction = handler;
  action.sa_flags = SA_SIGINFO;
  sigemptyset(&action.sa_mask);
  if (sigaction(SIGFPE, &action, 0)) return 2;
  uint64_t initial = read_fpscr();
  for (phase = 0; phase != 2; ++phase) {
    write_fpscr(0);
    volatile double zero = 0.0, invalid = zero / zero;
    (void)invalid;
    expected = (unsigned int)read_fpscr();
    valid = 0; seen = 0;
    if (raise(SIGFPE)) return 3;
    unsigned int restored = (unsigned int)read_fpscr();
    if (!valid || seen != SIGFPE || !(expected & 0xfff80000u)) return 4;
    if (phase == 0 && restored != expected) return 5;
    if (phase == 1 && restored != (expected & 0x0007f8ffu)) return 6;
    printf("OpenBSD PPC32 %s: saved=%x restored=%x PC=%lx SP=%lx\n",
           phase ? "port saved FPSCR reset survived signal return" :
                   "live-only reset restored sticky flags (negative control)",
           saved_before, restored, (unsigned long)saved_pc,
           (unsigned long)saved_sp);
  }
  write_fpscr(initial);
  return 0;
}
