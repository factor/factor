/* Copyright (C) 2026 Doug Coleman. BSD license. */
#include "../../vm/master.hpp"
extern "C" void factor_sparc_openbsd_spill();
extern "C" void factor_sparc_prepare_callstack(void*);

__attribute__((noinline)) static int verify_live_window() {
  factor::cell sp, parent, pc;
  __asm__ volatile("mov %%sp, %0\n\tmov %%i6, %1\n\tmov %%i7, %2"
                   : "=r"(sp), "=r"(parent), "=r"(pc));
  factor_sparc_openbsd_spill();
  factor::cell physical = sp + factor::SPARC_STACK_BIAS;
  auto* link = (factor::cell*)(physical + factor::FRAME_RETURN_ADDRESS);
  factor::cell original = *link;
  if (!(original & 3) ||
      factor::sparc_frame_predecessor(physical) != parent + factor::SPARC_STACK_BIAS ||
      factor::sparc_frame_return_address(physical) != pc + 8) return 1;
  factor::sparc_set_frame_return_address(physical, pc + 72);
  bool relocated = factor::sparc_frame_return_address(physical) == pc + 72 &&
                   (*link & 3) == (original & 3);
  factor::sparc_set_frame_return_address(physical, pc + 8);
  return (!relocated || *link != original) ? 2 : 0;
}
static int verify_unwind_masks() {
  auto* vm = new factor::factor_vm(pthread_self());
  int identity[2];
  auto* first = reinterpret_cast<factor::context*>(identity);
  auto* other = reinterpret_cast<factor::context*>(identity + 1);
  sigset_t original, outer = 0, inner = 0, separate = 0, current;
  if (sigprocmask(SIG_SETMASK, nullptr, &original)) return 4;
  sigaddset(&outer, SIGUSR1);
  sigaddset(&inner, SIGUSR2);
  sigaddset(&separate, SIGWINCH);
  vm->ctx = first;
  factor_sparc_prepare_callstack(vm);
  if (sigprocmask(SIG_SETMASK, nullptr, &current) || current != original)
    return 8;
  auto& a = vm->sparc_signal_slots[0];
  auto& b = vm->sparc_signal_slots[1];
  auto& c = vm->sparc_signal_slots[2];
  a.active = b.active = c.active = true;
  a.owner = b.owner = first; c.owner = other;
  a.frame = 0x9000; b.frame = 0x8000; c.frame = 0xa000;
  a.saved.resume_mask = outer; b.saved.resume_mask = inner;
  c.saved.resume_mask = separate;
  vm->abandon_sparc_signals(first, 0x8500);
  if (!a.active || b.active || !c.active ||
      sigprocmask(SIG_SETMASK, nullptr, &current) || current != inner) return 5;
  /* Replacing a callstack retires both pending depths of its owner. */
  b.active = true;
  factor_sparc_prepare_callstack(vm);
  if (a.active || !c.active ||
      b.active || sigprocmask(SIG_SETMASK, nullptr, &current) || current != outer)
    return 6;
  vm->abandon_sparc_signals(other, 0);
  if (c.active || sigprocmask(SIG_SETMASK, nullptr, &current) ||
      current != separate || sigprocmask(SIG_SETMASK, &original, nullptr)) return 7;
  return 0;
}
int main() {
  alignas(16) factor::cell raw[16] = {};
  raw[15] = 0x4000;
  factor::sparc_set_frame_return_address((factor::cell)raw, 0x4048);
  if (raw[15] != 0x4040 ||
      factor::sparc_frame_return_address((factor::cell)raw) != 0x4048) return 3;
  int result = verify_live_window();
  if (result) return result;
  result = verify_unwind_masks();
  if (result) return result;
  puts("PASS full CPP live StackGhost windows, raw snapshots and guarded unwind masks");
  fflush(stdout);
  /* This fixture constructs a VM without an image; its normal
   * destructor expects initialized special objects, so let process exit reclaim it. */
  _exit(0);
}
