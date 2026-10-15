#include "atomic-netbsd-hppa.hpp"
#ifdef FACTOR_NETBSD_HPPA_RAS
#include <sys/types.h>
#include <sys/ras.h>
#include <sys/sysctl.h>
#include <stdlib.h>

// Scratch registers may change before the final store. The kernel restarts
// interrupted sequences, including signal contexts, on this uniprocessor.
// The end labels immediately follow the store: a completed RMW is not repeated.
asm(".text\n.align 4\n"
    ".globl factor_ras_add,factor_ras_add_start,factor_ras_add_end\n"
    ".hidden factor_ras_add,factor_ras_add_start,factor_ras_add_end\n"
    ".type factor_ras_add,@function\nfactor_ras_add:\nfactor_ras_add_start:\n"
    "ldw 0(%r26),%r28\nadd %r28,%r25,%r20\nstw %r20,0(%r26)\n"
    "factor_ras_add_end:\nbv,n %r0(%r2)\n"
    ".globl factor_ras_cas,factor_ras_cas_start,factor_ras_cas_end\n"
    ".hidden factor_ras_cas,factor_ras_cas_start,factor_ras_cas_end\n"
    ".type factor_ras_cas,@function\nfactor_ras_cas:\nfactor_ras_cas_start:\n"
    "ldw 0(%r26),%r28\ncomb,<>,n %r25,%r28,factor_ras_cas_end\n"
    "stw %r24,0(%r26)\nfactor_ras_cas_end:\nbv,n %r0(%r2)\n");
extern "C" uint32_t factor_ras_add(volatile uint32_t*, uint32_t);
extern "C" uint32_t factor_ras_cas(volatile uint32_t*, uint32_t, uint32_t);
extern "C" char factor_ras_add_start[], factor_ras_add_end[];
extern "C" char factor_ras_cas_start[], factor_ras_cas_end[];

namespace factor { namespace atomic { namespace ras {
static bool register_sequences() {
  int mib[] = {CTL_HW, HW_NCPU}, cpus;
  size_t length = sizeof(cpus);
  if (sysctl(mib, 2, &cpus, &length, nullptr, 0) || cpus != 1)
    return false;
  size_t add_size = uintptr_t(factor_ras_add_end) - uintptr_t(factor_ras_add_start);
  size_t cas_size = uintptr_t(factor_ras_cas_end) - uintptr_t(factor_ras_cas_start);
  if (rasctl(factor_ras_add_start, add_size, RAS_INSTALL))
    return false;
  if (rasctl(factor_ras_cas_start, cas_size, RAS_INSTALL)) {
    // No caller can execute our sequences until initialization completes.
    rasctl(factor_ras_add_start, add_size, RAS_PURGE);
    return false;
  }
  return true;
}
// Only ordinary VM construction reaches this C++ initialization guard. Publish
// its immutable result with native byte atomics before any VM becomes visible.
// Fork inherits both registrations and this result; no PID cache is required.
static bool supported;
bool initialize() {
  static const bool registered = register_sequences();
  __atomic_store_n(&supported, registered, __ATOMIC_SEQ_CST);
  return registered;
}
bool available() {
  return __atomic_load_n(&supported, __ATOMIC_SEQ_CST);
}
uint32_t fetch_add(volatile uint32_t* ptr, uint32_t value) {
  if (!available()) abort();
  __sync_synchronize();
  uint32_t previous = factor_ras_add(ptr, value);
  __sync_synchronize();
  return previous;
}
bool cas(volatile uint32_t* ptr, uint32_t old_value, uint32_t new_value) {
  if (!available()) abort();
  __sync_synchronize();
  bool exchanged = factor_ras_cas(ptr, old_value, new_value) == old_value;
  __sync_synchronize();
  return exchanged;
}
} } }
#endif
