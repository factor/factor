#include <type_traits>
#include "atomic-netbsd-sparc.hpp"
#include "atomic-netbsd-hppa.hpp"
#include "atomic-openbsd-hppa.hpp"
#if defined(FACTOR_NETBSD_SPARC_RAS) || defined(FACTOR_NETBSD_HPPA_RAS)
#define FACTOR_NETBSD_RAS 1
#endif

// Atomic publication for VM state shared with native helper threads.
// A volatile access surrounded by fences is still a C++ data race.
#if defined(_MSC_VER)
#include <intrin.h>
#endif
#if defined(__m88k__) || defined(__m88000__)
// XMEM exchanges words, but provides no arithmetic RMW or CAS. OpenBSD's
// privileged kernel atomics are unavailable to user signal handlers.
#define FACTOR_ATOMIC_RMW_UNAVAILABLE 1
#elif defined(__NetBSD__) && defined(__vax__)
// libc CAS can fall back to unmasked hashed locks. A profiling signal may
// interrupt their owner, so publication support cannot enable sampling RMW.
#define FACTOR_ATOMIC_RMW_UNAVAILABLE 1
#elif defined(__NetBSD__) && defined(__SH3__)
// Native SH3 load/store publication is independent of libc's locked RMW.
// A signal could interrupt the lock owner, so sampling remains unavailable.
#define FACTOR_ATOMIC_RMW_UNAVAILABLE 1
#endif

namespace factor {
namespace atomic {
#if !defined(_MSC_VER)
template <typename T>
constexpr bool publication_lock_free() {
#if defined(__sparc_v8__) && __SIZEOF_POINTER__ == 4 && \
    defined(__GNUC__) && !defined(__clang__)
  // GCC's general lock-free query also requires compare-and-swap, absent
  // from V8. Its atomic_load/store QI/SI patterns instead emit indivisible
  // LDUB/LD/STB/ST with STBAR/LDSTUB barriers as required by the memory model.
  // Keep the C++ atomic builtins: a volatile load with fences is not atomic
  // in the language memory model. No runtime helper or lock is involved.
  // https://gcc.gnu.org/git/?p=gcc.git;a=blob;f=gcc/config/sparc/sync.md
  return sizeof(T) == 1 || sizeof(T) == 4;
#elif (defined(__NetBSD__) || defined(__OpenBSD__)) && defined(__hppa__) && \
    __SIZEOF_POINTER__ == 4 && \
    defined(__GNUC__) && !defined(__clang__)
  // Native GCC emits indivisible LDB/LDW/STB/STW with aligned stack LDCW
  // barriers. The general query remains false because it also requires CAS;
  // NetBSD arithmetic RMW uses registered RAS; OpenBSD uses the separately
  // initialized native signal-masked LDCW adapter.
  // https://gcc.gnu.org/git/?p=gcc.git;a=blob;f=gcc/config/pa/pa.md
  return sizeof(T) == 1 || sizeof(T) == 4;
#elif defined(__NetBSD__) && defined(__riscv) && __riscv_xlen == 64 && \
    defined(__riscv_atomic) && defined(__GNUC__) && !defined(__clang__)
  // GCC's general query also requires CAS. GCC 12 emits fenced LBU/SB for
  // byte seq_cst publication while byte CAS uses an external helper. Aligned
  // word publication uses fenced LW/LD and AMOSWAP.W/D with the A extension.
  // Keep compiler atomic builtins, natural alignment, and the VM's widths.
  // https://gcc.gnu.org/git/?p=gcc.git;a=blob;f=gcc/config/riscv/sync.md
  return (std::is_integral<T>::value || std::is_pointer<T>::value) &&
         (sizeof(T) == 1 || sizeof(T) == 4 || sizeof(T) == 8) &&
         alignof(T) >= sizeof(T);
#elif defined(__NetBSD__) && defined(__SH3__) && __SIZEOF_POINTER__ == 4 && \
    defined(__GNUC__) && !defined(__clang__)
  // NetBSD's SH3 ABI runs on one CPU and uses no-op memory barriers.
  // Native GCC emits indivisible MOV.B/MOV.L with no runtime helper.
  // Keep the compiler's seq_cst atomics and reject wider publication.
  // common/lib/libc/arch/sh3/atomic/Makefile.inc and sys/arch/sh3/include/cpu.h
  return (std::is_integral<T>::value || std::is_pointer<T>::value) &&
         (sizeof(T) == 1 || sizeof(T) == 4) && alignof(T) >= sizeof(T);
#elif defined(__NetBSD__) && defined(__vax__) && __SIZEOF_POINTER__ == 4 && \
    defined(__GNUC__) && !defined(__clang__)
  // Native GCC emits MOVB/MOVL with no helper. VAX orders reads and writes on
  // UP and MP; aligned byte/longword publication needs no hardware fence.
  // Keep the compiler atomic builtins and reject wider operations and RMW.
  // OpenVMS Programming Concepts 6.2.1-6.2.2 describes this hardware contract.
  // https://docs.vmssoftware.com/vsi-openvms-programming-concepts-manual-volume-i/
  return sizeof(T) == 1 || sizeof(T) == 4;
#elif defined(__clang__) && defined(__OpenBSD__) && \
    (defined(__m88k__) || defined(__m88000__)) && __SIZEOF_POINTER__ == 4 && \
    defined(__M88K_OPENBSD_ATOMIC_PUBLICATION__) && \
    __M88K_OPENBSD_ATOMIC_PUBLICATION__ == 1
  // The tested backend preserves atomic MMOs and emits indivisible byte/word
  // LD/ST between OpenBSD TB1 128 barriers. Its marker describes only these
  // publication operations: global CAS/RMW lock-free queries stay false.
  return sizeof(T) == 1 || sizeof(T) == 4;
#else
  return __atomic_always_lock_free(sizeof(T), nullptr);
#endif
}
#endif
// Sampling both accumulates and drains counters from multiple native threads.
// Publication support alone cannot make these arithmetic updates safe.
inline bool rmw_supported() {
#if defined(FACTOR_ATOMIC_RMW_UNAVAILABLE)
  return false;
#elif defined(FACTOR_NETBSD_RAS)
  return ras::available();
#elif defined(FACTOR_OPENBSD_HPPA_MASKED_RMW)
  return openbsd_hppa::available();
#else
  return true;
#endif
}
template <typename T>
FACTOR_FORCE_INLINE static T load(volatile T* ptr) {
  static_assert(sizeof(T) == 1 || sizeof(T) == 4 || sizeof(T) == 8,
                "Unsupported VM atomic width");
#if defined(_MSC_VER)
  if constexpr (sizeof(T) == 1)
    return (T)_InterlockedCompareExchange8((volatile char*)ptr, 0, 0);
  else if constexpr (sizeof(T) == 4)
    return (T)_InterlockedCompareExchange((volatile long*)ptr, 0, 0);
  else
    return (T)_InterlockedCompareExchange64((volatile __int64*)ptr, 0, 0);
#else
  static_assert(publication_lock_free<T>(),
                "VM signal handlers require lock-free atomics");
  return __atomic_load_n(ptr, __ATOMIC_SEQ_CST);
#endif
}

template <typename T>
FACTOR_FORCE_INLINE static void store(volatile T* ptr, T val) {
  static_assert(sizeof(T) == 1 || sizeof(T) == 4 || sizeof(T) == 8,
                "Unsupported VM atomic width");
#if defined(_MSC_VER)
  if constexpr (sizeof(T) == 1)
    _InterlockedExchange8((volatile char*)ptr, (char)val);
  else if constexpr (sizeof(T) == 4)
    _InterlockedExchange((volatile long*)ptr, (long)val);
  else
    _InterlockedExchange64((volatile __int64*)ptr, (__int64)val);
#else
  static_assert(publication_lock_free<T>(),
                "VM signal handlers require lock-free atomics");
#ifdef FACTOR_OPENBSD_HPPA_MASKED_RMW
  if constexpr (sizeof(T) == 4 && std::is_integral<T>::value) {
    openbsd_hppa::store(ptr, val);
    return;
  }
#endif
  __atomic_store_n(ptr, val, __ATOMIC_SEQ_CST);
#endif
}
}
}
