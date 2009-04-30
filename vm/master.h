#ifndef __FACTOR_MASTER_H__
#define __FACTOR_MASTER_H__

#ifndef WINCE
#include <errno.h>
#endif

#ifdef FACTOR_DEBUG
#include <assert.h>
#endif

#include <fcntl.h>
#include <limits.h>
#include <math.h>
#include <stdbool.h>
#include <setjmp.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/param.h>

#include "layouts.h"
#include "platform.h"
#include "primitives.h"
#include "run.h"
#include "profiler.h"
#include "errors.h"
#include "bignumint.h"
#include "bignum.h"
#include "write_barrier.h"
#include "data_heap.h"
#include "data_gc.h"
#include "local_roots.h"
#include "debug.h"
#include "arrays.h"
#include "strings.h"
#include "booleans.h"
#include "byte_arrays.h"
#include "tuples.h"
#include "words.h"
#include "math.h"
#include "float_bits.h"
#include "io.h"
#include "code_gc.h"
#include "code_block.h"
#include "code_heap.h"
#include "image.h"
#include "callstack.h"
#include "alien.h"
#include "quotations.h"
#include "jit.h"
#include "dispatch.h"
#include "inline_cache.h"
#include "factor.h"
#include "utilities.h"

#endif /* __FACTOR_MASTER_H__ */
