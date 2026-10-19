#pragma once
#include <stdint.h>

// HPPA publication uses native loads/stores; signal-safe RMW requires UP RAS.
#if defined(__NetBSD__) && defined(__hppa__) && __SIZEOF_POINTER__ == 4
#define FACTOR_NETBSD_HPPA_RAS 1
namespace factor { namespace atomic { namespace ras {
// Call from ordinary code before publishing a VM or enabling sampling.
// The result is immutable, process-wide, and inherited with RAS across fork.
bool initialize();
bool available();
uint32_t fetch_add(volatile uint32_t* ptr, uint32_t value);
bool cas(volatile uint32_t* ptr, uint32_t old_value, uint32_t new_value);
} } }
#endif
