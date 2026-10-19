// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
#include <signal.h>

namespace factor {

// Linux SPARC SA_SIGINFO does not pass a ucontext_t. On SPARC64 the
// third argument points to siginfo followed by registers (sigcontext).
// On SPARC32 it points directly at pt_regs, matching sigcontext.si_regs.
// https://github.com/torvalds/linux/blob/master/arch/sparc/kernel/signal_32.c
// https://github.com/bminor/glibc/blob/master/sysdeps/unix/sysv/linux/sparc/sparc64/sigcontextinfo.h
inline auto& sparc_signal_pc(void* raw) {
#if __SIZEOF_POINTER__ == 8
  return static_cast<struct sigcontext*>(raw)->sigc_regs.tpc;
#else
  return static_cast<struct sigcontext*>(raw)->si_regs.pc;
#endif
}

inline auto& sparc_signal_npc(void* raw) {
#if __SIZEOF_POINTER__ == 8
  return static_cast<struct sigcontext*>(raw)->sigc_regs.tnpc;
#else
  return static_cast<struct sigcontext*>(raw)->si_regs.npc;
#endif
}

inline auto& sparc_signal_sp(void* raw) {
#if __SIZEOF_POINTER__ == 8
  return static_cast<struct sigcontext*>(raw)->sigc_regs.u_regs[14];
#else
  return static_cast<struct sigcontext*>(raw)->si_regs.u_regs[14];
#endif
}

// Redirect both architectural program counters; changing only PC leaves
// the old delay-slot instruction in NPC and executes it at the new target.
inline void sparc_redirect_signal(void* raw, unsigned long target) {
  sparc_signal_pc(raw) = target;
  sparc_signal_npc(raw) = target + 4;
}

inline unsigned long sparc_signal_stack_address(void* raw) {
#if __SIZEOF_POINTER__ == 8
  return sparc_signal_sp(raw) + 2047;
#else
  return sparc_signal_sp(raw);
#endif
}

}
