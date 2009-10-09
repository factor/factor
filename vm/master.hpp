#ifndef __FACTOR_MASTER_H__
#define __FACTOR_MASTER_H__

#define _THREAD_SAFE
#define _REENTRANT

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
#include <algorithm>
#include <set>
#include <vector>

#if __GNUC__ == 4
        #include <tr1/unordered_map>

	namespace factor
	{
		using std::tr1::unordered_map;
	}
#elif __GNUC__ == 3
        #include <boost/unordered_map.hpp>

	namespace factor
	{
		using boost::unordered_map;
	}
#else
        #error Factor requires GCC 3.x or later
#endif

/* Forward-declare this since it comes up in function prototypes */
namespace factor
{
	struct factor_vm;
}

/* Factor headers */
#include "layouts.hpp"
#include "platform.hpp"
#include "primitives.hpp"
#include "stacks.hpp"
#include "segments.hpp"
#include "contexts.hpp"
#include "run.hpp"
#include "profiler.hpp"
#include "errors.hpp"
#include "bignumint.hpp"
#include "bignum.hpp"
#include "code_block.hpp"
#include "zone.hpp"
#include "write_barrier.hpp"
#include "old_space.hpp"
#include "aging_space.hpp"
#include "tenured_space.hpp"
#include "data_heap.hpp"
#include "gc.hpp"
#include "debug.hpp"
#include "strings.hpp"
#include "tuples.hpp"
#include "words.hpp"
#include "float_bits.hpp"
#include "io.hpp"
#include "heap.hpp"
#include "image.hpp"
#include "alien.hpp"
#include "code_heap.hpp"
#include "vm.hpp"
#include "tagged.hpp"
#include "local_roots.hpp"
#include "collector.hpp"
#include "copying_collector.hpp"
#include "nursery_collector.hpp"
#include "aging_collector.hpp"
#include "to_tenured_collector.hpp"
#include "full_collector.hpp"
#include "callstack.hpp"
#include "generic_arrays.hpp"
#include "arrays.hpp"
#include "math.hpp"
#include "booleans.hpp"
#include "byte_arrays.hpp"
#include "jit.hpp"
#include "quotations.hpp"
#include "dispatch.hpp"
#include "inline_cache.hpp"
#include "factor.hpp"
#include "utilities.hpp"

#endif /* __FACTOR_MASTER_H__ */
