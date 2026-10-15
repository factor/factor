// Production literal helper; no runtime or standard-library dependencies.
typedef unsigned int uint32_t;
typedef int int32_t;
extern "C" void abort();
#define FACTOR_ASSERT(x) do { if (!(x)) abort(); } while (0)
#include "evidence/production-m88k-literal.hpp"
#ifndef PROBE_FUNCTION
#define PROBE_FUNCTION literal_load_o2
#endif
extern "C" unsigned PROBE_FUNCTION(const unsigned* words) {
 return factor::m88k_load_literal32(words);
}
