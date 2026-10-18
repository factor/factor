// Native context redirection; included after the complete VM declaration.
#pragma once

#if defined(FACTOR_HPPA)
#include "os-unix-hppa-signals.hpp"
#elif defined(FACTOR_PPC)
#include "os-unix-ppc-signals.hpp"
#elif defined(FACTOR_SPARC)
#include "os-unix-sparc-signals.hpp"
#elif defined(FACTOR_M88K)
#include "os-openbsd-m88k-signals.hpp"
#else
#include "os-unix-generic-signals.hpp"
#endif

namespace factor::platform {
#if defined(__NetBSD__) && defined(FACTOR_ALPHA)
using signal_fpu_scope = netbsd_alpha_signal_fpu_scope;
#else
struct signal_fpu_scope {
  explicit signal_fpu_scope(void*) {}
  void restore() {}
};
#endif

inline unsigned int signal_fpu_status(void* uap, siginfo_t* info) {
#if defined(FACTOR_LOONGARCH64) || (defined(__linux__) && \
    (defined(FACTOR_ARM64) || defined(FACTOR_HPPA) || defined(FACTOR_SPARC)))
  return factor::signal_fpu_status(uap_fpu_status(uap), info->si_code);
#elif defined(__NetBSD__) && defined(FACTOR_MIPS)
  return factor::signal_fpu_status(uap_fpu_status(uap), info->si_trap);
#else
  (void)info;
  return fpu_status(uap_fpu_status(uap));
#endif
}
}
