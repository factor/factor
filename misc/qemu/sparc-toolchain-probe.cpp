#ifdef NDEBUG
#error This probe requires assertions enabled
#endif
// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
// Standalone Zig/C++ interoperability probe, not a Factor VM test.
#include <cassert>
#include <cstdio>
#include <cstdint>
#include <initializer_list>
#include <signal.h>
#include <cstddef>
#include <cstring>
#include "../../vm/sparc-linux-signal.h"
extern "C" unsigned long probe_add(unsigned long, unsigned long);
extern "C" double probe_fp(double, double);
extern "C" unsigned probe_relocation(uint64_t);
extern "C" unsigned probe_signal_offsets(size_t, size_t, size_t);
extern "C" void probe_redirect(void*, unsigned long);
extern "C" unsigned probe_frames();
extern "C" unsigned probe_runtime(size_t);
extern "C" unsigned probe_native_word();
extern "C" unsigned probe_callsites(size_t);
extern "C" uintptr_t factor_sparc_prepare_signal_bridge(void*, void*, uintptr_t);
extern "C" uint32_t factor_sparc_fpu_status(void*);
extern "C" void factor_sparc_clear_fpu_status(void*);
struct zig_sigaction { void (*handler)(int); sigset_t mask; unsigned flags; void (*restorer)(); };
extern "C" int factor_sparc_sigaction_bridge(int, const zig_sigaction*, zig_sigaction*);
static void action_probe(int) {}
static void probe_signal_bridge() {
  zig_sigaction previous{}, action{};
  action.handler = action_probe;
  sigemptyset(&action.mask);
  action.flags = SA_SIGINFO | SA_ONSTACK | SA_RESTART;
  assert(factor_sparc_sigaction_bridge(SIGUSR1, &action, &previous) == 0);
  struct sigaction actual{};
  assert(sigaction(SIGUSR1, nullptr, &actual) == 0);
  assert(actual.sa_handler == action_probe && actual.sa_flags == (int)action.flags);
  assert(factor_sparc_sigaction_bridge(SIGUSR1, &previous, nullptr) == 0);
  alignas(16) unsigned char original[2048]{};
  alignas(16) unsigned char fp[280]{};
  alignas(16) uintptr_t windows[128]{};
  factor_sparc_signal_storage slot{};
  const bool wide = sizeof(uintptr_t) == 8;
  unsigned char* raw = original + (wide ? 192 : 224);
  const size_t regs_offset = wide ? 128 : 16;
  const size_t pc_offset = wide ? 264 : 4;
  const size_t fpu_offset = wide ? 288 : 88;
  auto* regs = reinterpret_cast<uintptr_t*>(raw + regs_offset);
  auto* pc = reinterpret_cast<uintptr_t*>(raw + pc_offset);
  const uintptr_t physical = reinterpret_cast<uintptr_t>(&windows[64]);
  regs[14] = physical - (wide ? 2047 : 0);
  pc[0] = 0x12340; pc[1] = 0x12344;
  *reinterpret_cast<uintptr_t*>(raw + fpu_offset) = reinterpret_cast<uintptr_t>(fp);
  if (wide) *reinterpret_cast<uint64_t*>(fp + 256) = UINT64_C(0x400000001c3ff);
  else *reinterpret_cast<uint32_t*>(fp + 256) = UINT32_C(0xc001c3ff);
  assert(factor_sparc_fpu_status(raw) & 0x3ff);
  factor_sparc_clear_fpu_status(raw);
  assert((factor_sparc_fpu_status(raw) & 0x1c3ff) == 0);
  const uintptr_t fake = factor_sparc_prepare_signal_bridge(raw, &slot, 0x23450);
  assert(fake == physical - (wide ? 192 : 112));
  assert(regs[14] == fake - (wide ? 2047 : 0));
  assert(pc[0] == 0x23450 && pc[1] == 0x23454);
  assert(reinterpret_cast<uintptr_t*>(fake)[14] == physical - (wide ? 2047 : 0));
  assert(reinterpret_cast<uintptr_t*>(fake)[15] == 0x12338);
  assert(*reinterpret_cast<uintptr_t*>(fake + (wide ? 176 : 96)) == reinterpret_cast<uintptr_t>(slot.bytes));
}
int main() {
  probe_signal_bridge();
  assert(probe_callsites(0) == 0);
  assert(probe_native_word() == 0x4f000018);
  assert(probe_runtime(0) == 0);
  assert(probe_frames() == 0);
  struct sigcontext context{};
#if __SIZEOF_POINTER__ == 8
  assert(probe_signal_offsets(offsetof(sigcontext, sigc_regs.tpc), offsetof(sigcontext, sigc_regs.u_regs[14]), offsetof(sigcontext, sigc_regs.tnpc)) == 0);
  probe_redirect(&context, 0x12340);
  assert(context.sigc_regs.tpc == 0x12340 && context.sigc_regs.tnpc == 0x12344);
#else
  assert(probe_signal_offsets(offsetof(sigcontext, si_regs.pc), offsetof(sigcontext, si_regs.u_regs[14]), offsetof(sigcontext, si_regs.npc)) == 0);
  probe_redirect(&context, 0x12340);
  assert(context.si_regs.pc == 0x12340 && context.si_regs.npc == 0x12344);
#endif
  const uint64_t values[] = {0, 1, 0xffffffff, 0x100000000, 0x8000000000000000, 0xfedcba9876543210, UINT64_MAX};
  for (uint64_t value : values)
    assert(probe_relocation(value) == 0);
  assert(probe_add(19, 23) == 42);
  assert(probe_add(~0UL - 42, 42) == ~0UL);
  assert(probe_fp(1.25, 2.5) == 3.75);
  assert(probe_fp(-1.25, 1.25) == 0);
  printf("SPARC%zu Zig object/C++ linkage integer+FP+relocation calls passed\n", sizeof(void*) * 8);
}
