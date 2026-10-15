// Run the native publication driver against the actual VM atomic wrappers.
#include <stdint.h>
namespace factor {
using cell = uintptr_t;
using fixnum = intptr_t;
}
#include "../../../vm/atomic-gcc.hpp"
static_assert(!__atomic_always_lock_free(1, nullptr), "CAS/RMW query must stay false");
static_assert(!__atomic_always_lock_free(4, nullptr), "CAS/RMW query must stay false");
extern "C" unsigned char m88k_publication_load8(volatile unsigned char* p) {
  return factor::atomic::load(p);
}
extern "C" void m88k_publication_store8(volatile unsigned char* p, unsigned char v) {
  factor::atomic::store(p, v);
}
extern "C" unsigned m88k_publication_load32(volatile unsigned* p) {
  return factor::atomic::load(p);
}
extern "C" void m88k_publication_store32(volatile unsigned* p, unsigned v) {
  factor::atomic::store(p, v);
}
extern "C" unsigned m88k_publication_rmw_supported() {
  return factor::atomic::rmw_supported();
}
extern "C" void m88k_publication_fence() {
  factor::atomic::fence();
}
// These entrypoints must fail rather than return fabricated arithmetic results.
// Their emitted objects also prove no unresolved __sync helper is introduced.
extern "C" factor::cell m88k_unavailable_add(volatile factor::cell* p) {
  return factor::atomic::fetch_add(p, factor::cell(1));
}
extern "C" unsigned m88k_unavailable_cas(volatile factor::cell* p) {
  return factor::atomic::cas(p, factor::cell(0), factor::cell(1));
}
