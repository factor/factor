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
#include <map>
#include <set>
#include <vector>
#include <iostream>

/* Forward-declare this since it comes up in function prototypes */
namespace factor
{
	struct factor_vm;
}

/* Factor headers */
#include "layouts.hpp"
#include "platform.hpp"
#include "primitives.hpp"
#include "segments.hpp"
#include "contexts.hpp"
#include "run.hpp"
#include "objects.hpp"
#include "profiler.hpp"
#include "errors.hpp"
#include "bignumint.hpp"
#include "bignum.hpp"
#include "booleans.hpp"
#include "instruction_operands.hpp"
#include "code_blocks.hpp"
#include "bump_allocator.hpp"
#include "bitwise_hacks.hpp"
#include "mark_bits.hpp"
#include "free_list.hpp"
#include "free_list_allocator.hpp"
#include "write_barrier.hpp"
#include "object_start_map.hpp"
#include "nursery_space.hpp"
#include "aging_space.hpp"
#include "tenured_space.hpp"
#include "data_heap.hpp"
#include "code_heap.hpp"
#include "gc.hpp"
#include "debug.hpp"
#include "strings.hpp"
#include "tuples.hpp"
#include "words.hpp"
#include "float_bits.hpp"
#include "io.hpp"
#include "image.hpp"
#include "alien.hpp"
#include "callbacks.hpp"
#include "dispatch.hpp"
#include "vm.hpp"
#include "allot.hpp"
#include "tagged.hpp"
#include "data_roots.hpp"
#include "code_roots.hpp"
#include "generic_arrays.hpp"
#include "slot_visitor.hpp"
#include "collector.hpp"
#include "copying_collector.hpp"
#include "nursery_collector.hpp"
#include "aging_collector.hpp"
#include "to_tenured_collector.hpp"
#include "code_block_visitor.hpp"
#include "compaction.hpp"
#include "full_collector.hpp"
#include "callstack.hpp"
#include "arrays.hpp"
#include "math.hpp"
#include "byte_arrays.hpp"
#include "jit.hpp"
#include "quotations.hpp"
#include "inline_cache.hpp"
#include "factor.hpp"
#include "utilities.hpp"

#endif /* __FACTOR_MASTER_H__ */
