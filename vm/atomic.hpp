// Atomic publication for VM state shared with native helper threads.
// A volatile access surrounded by fences is still a C++ data race.
#if defined(_MSC_VER)
#include <intrin.h>
#endif

namespace factor {
namespace atomic {
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
  static_assert(__atomic_always_lock_free(sizeof(T), nullptr),
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
  static_assert(__atomic_always_lock_free(sizeof(T), nullptr),
                "VM signal handlers require lock-free atomics");
  __atomic_store_n(ptr, val, __ATOMIC_SEQ_CST);
#endif
}
}
}
