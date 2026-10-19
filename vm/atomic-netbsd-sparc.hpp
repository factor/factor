#pragma once
#include <stdint.h>

// V8 has publication loads/stores, but no arithmetic RMW or CAS instruction.
#if defined(__NetBSD__) && defined(__sparc_v8__) && __SIZEOF_POINTER__ == 4
#define FACTOR_NETBSD_SPARC_RAS 1
namespace factor { namespace atomic { namespace ras {
// Call from ordinary code before publishing a VM or enabling sampling.
// The result is immutable, process-wide, and inherited with RAS across fork.
bool initialize();
bool available();
uint32_t fetch_add(volatile uint32_t* ptr, uint32_t value);
bool cas(volatile uint32_t* ptr, uint32_t old_value, uint32_t new_value);
} } }
#endif
