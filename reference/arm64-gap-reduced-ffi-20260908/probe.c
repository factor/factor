/* Compile the same independent C fixtures without the other FFI tests. */
#include <stdarg.h>
#if __STDC_HOSTED__
#include <string.h>
#else
#define memcpy __builtin_memcpy
#endif
#define FACTOR_EXPORT __attribute__((visibility("default")))
#include "../../vm/ffi_test_small.h"
