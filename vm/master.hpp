#ifndef __FACTOR_MASTER_H__
#define __FACTOR_MASTER_H__

#ifndef WINCE
#include <errno.h>
#endif

#ifdef FACTOR_DEBUG
#include <assert.h>
#endif

/* C headers */
#include <fcntl.h>
#include <limits.h>
#include <math.h>
#include <stdbool.h>
#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

/* C++ headers */
#if __GNUC__ == 4
        #include <tr1/unordered_map>
        #define unordered_map std::tr1::unordered_map
#elif __GNUC__ == 3
        #include <boost/unordered_map.hpp>
        #define unordered_map boost::unordered_map
#else
        #error Factor requires GCC 3.x or later
#endif

/* Factor headers */
#include "layouts.hpp"
#include "platform.hpp"
#include "primitives.hpp"
#include "stacks.hpp"
#include "segments.hpp"
#include "contexts.hpp"
#include "run.hpp"
#include "tagged.hpp"
#include "profiler.hpp"
#include "errors.hpp"
#include "bignumint.hpp"
#include "bignum.hpp"
#include "data_heap.hpp"
#include "write_barrier.hpp"
#include "data_gc.hpp"
#include "local_roots.hpp"
#include "generic_arrays.hpp"
#include "debug.hpp"
#include "arrays.hpp"
#include "strings.hpp"
#include "booleans.hpp"
#include "byte_arrays.hpp"
#include "tuples.hpp"
#include "words.hpp"
#include "math.hpp"
#include "float_bits.hpp"
#include "io.hpp"
#include "code_gc.hpp"
#include "code_block.hpp"
#include "code_heap.hpp"
#include "image.hpp"
#include "callstack.hpp"
#include "alien.hpp"
#include "jit.hpp"
#include "quotations.hpp"
#include "dispatch.hpp"
#include "inline_cache.hpp"
#include "factor.hpp"
#include "utilities.hpp"

#endif /* __FACTOR_MASTER_H__ */
