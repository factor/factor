#ifndef __FACTOR_MASTER_H__
#define __FACTOR_MASTER_H__

#ifndef _THREAD_SAFE
#define _THREAD_SAFE
#endif

#ifndef _REENTRANT
#define _REENTRANT
#endif

#include <errno.h>

// C headers
#include <fcntl.h>
#include <limits.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <wchar.h>
#include <stdint.h>
#if defined(_MSC_VER) || defined(__MINGW32__)
#include <io.h>
#endif

// C++ headers
#include <algorithm>
#include <list>
#include <map>
#include <set>
#include <unordered_map>
#include <vector>
#include <iostream>
#include <iomanip>
#include <limits>
#include <sstream>
#include <string>

#if defined(FACTOR_ASAN)
extern "C" void __sanitizer_start_switch_fiber(
    void** fake_stack_save, const void* bottom, size_t size);
extern "C" void __sanitizer_finish_switch_fiber(
    void* fake_stack_save, const void** bottom_old, size_t* size_old);
#endif
#if defined(FACTOR_TSAN)
extern "C" void* __tsan_get_current_fiber();
extern "C" void* __tsan_create_fiber(unsigned flags);
extern "C" void __tsan_destroy_fiber(void* fiber);
extern "C" void __tsan_switch_to_fiber(void* fiber, unsigned flags);
extern "C" void __tsan_acquire(void* addr);
extern "C" void __tsan_release(void* addr);
#endif

#if defined(__clang__)
#if defined(__i386__) || defined(__x86_64__)
#define FACTOR_ALIGN_STACK __attribute__((force_align_arg_pointer))
#else
#define FACTOR_ALIGN_STACK
#endif
#define FACTOR_PRESERVE_ALL __attribute__((preserve_all)) FACTOR_ALIGN_STACK
#if defined(__aarch64__)
#define FACTOR_PRESERVE_CALLBACK_RETURN FACTOR_PRESERVE_ALL
#else
#define FACTOR_PRESERVE_CALLBACK_RETURN
#endif
#define FACTOR_NO_SANITIZE_ADDRESS \
  __attribute__((no_sanitize("address"), noinline))
#define FACTOR_NO_SANITIZE_FIBER \
  __attribute__((no_sanitize("address", "thread"), \
                 disable_sanitizer_instrumentation, noinline))
#else
#define FACTOR_ALIGN_STACK
#define FACTOR_PRESERVE_ALL
#define FACTOR_PRESERVE_CALLBACK_RETURN
#define FACTOR_NO_SANITIZE_ADDRESS \
  __attribute__((no_sanitize_address, noinline))
#define FACTOR_NO_SANITIZE_FIBER __attribute__((noinline))
#endif

#if defined(__has_include)
#if __has_include(<valgrind/valgrind.h>)
#include <valgrind/valgrind.h>
#define FACTOR_HAS_VALGRIND 1
#endif
#endif

#define FACTOR_STRINGIZE_I(x) #x
#define FACTOR_STRINGIZE(x) FACTOR_STRINGIZE_I(x)

// Record compiler version
#if defined(__clang__)
#define FACTOR_COMPILER_VERSION "Clang (GCC " __VERSION__ ")"
#elif defined(__INTEL_COMPILER)
#define FACTOR_COMPILER_VERSION \
  "Intel C Compiler " FACTOR_STRINGIZE(__INTEL_COMPILER)
#elif defined(__MINGW32__)
#define FACTOR_COMPILER_VERSION "MinGW (GCC " __VERSION__ ")"
#elif defined(__GNUC__)
#define FACTOR_COMPILER_VERSION "GCC " __VERSION__
#elif defined(_MSC_FULL_VER)
#define FACTOR_COMPILER_VERSION \
  "Microsoft Visual C++ " FACTOR_STRINGIZE(_MSC_FULL_VER)
#else
#define FACTOR_COMPILER_VERSION "unknown"
#endif

#if defined(FACTOR_REPRODUCIBLE)
  #define FACTOR_COMPILE_TIME "[reproducible]"
#else
  // Record compilation time
  #define FACTOR_COMPILE_TIME  __DATE__ " " __TIME__
#endif

// Detect target CPU type
#if defined(__arm__)
#define FACTOR_ARM32
#elif defined(__aarch64__) || defined(_M_ARM64)
#define FACTOR_ARM64
#define FACTOR_64
#elif defined(__amd64__) || defined(__x86_64__) || defined(_M_AMD64)
#define FACTOR_AMD64
#define FACTOR_64
#elif defined(i386) || defined(__i386) || defined(__i386__) || defined(_M_IX86)
#define FACTOR_X86
#elif(defined(__POWERPC__) || defined(__ppc__) || defined(_ARCH_PPC)) && \
    (defined(__PPC64__) || defined(__64BIT__))
#define FACTOR_PPC64
#define FACTOR_PPC
#define FACTOR_64
#elif defined(__POWERPC__) || defined(__ppc__) || defined(_ARCH_PPC)
#define FACTOR_PPC32
#define FACTOR_PPC
#else
#error "Unsupported architecture"
#endif

#if defined(_MSC_VER) || defined (__MINGW32__)
#define WINDOWS
#define WINNT
#elif defined(WIN32)
#define WINDOWS
#endif

// Forward-declare this since it comes up in function prototypes
namespace factor { struct factor_vm; }

// Factor headers
#include "zstd.hpp"
#include "assert.hpp"
#include "debug.hpp"
#include "layouts.hpp"
#include "platform.hpp"
#include "utilities.hpp"
#include "primitives.hpp"
#include "errors.hpp"
#include "segments.hpp"
#include "gc_info.hpp"
#include "contexts.hpp"
#include "run.hpp"
#include "objects.hpp"
#include "sampling_profiler.hpp"
#include "bignumint.hpp"
#include "bignum.hpp"
#include "booleans.hpp"
#include "instruction_operands.hpp"
#include "tagged.hpp"
#include "code_blocks.hpp"
#include "bump_allocator.hpp"
#include "bitwise_hacks.hpp"
#include "mark_bits.hpp"
#include "fixup.hpp"
#include "free_list.hpp"
#include "write_barrier.hpp"
#include "object_start_map.hpp"
#include "aging_space.hpp"
#include "tenured_space.hpp"
#include "data_heap.hpp"
#include "code_heap.hpp"
#include "gc.hpp"
#include "float_bits.hpp"
#include "io.hpp"
#include "image.hpp"
#include "callbacks.hpp"
#include "dispatch.hpp"
#include "vm.hpp"
#include "allot.hpp"
#include "data_roots.hpp"
#include "code_roots.hpp"
#include "generic_arrays.hpp"
#include "callstack.hpp"
#include "slot_visitor.hpp"
#include "to_tenured_collector.hpp"
#include "arrays.hpp"
#include "math.hpp"
#include "byte_arrays.hpp"
#include "jit.hpp"
#include "quotations.hpp"
#include "inline_cache.hpp"
#include "mvm.hpp"
#include "factor.hpp"

#endif // __FACTOR_MASTER_H__
