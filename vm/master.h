#ifndef __FACTOR_MASTER_H__
#define __FACTOR_MASTER_H__

#ifndef WINCE
	#include <errno.h>
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
#include "debug.h"
#include "run.h"
#include "errors.h"
#include "bignumint.h"
#include "bignum.h"
#include "data_gc.h"
#include "types.h"
#include "math.h"
#include "float_bits.h"
#include "io.h"
#include "code_gc.h"
#include "code_heap.h"
#include "image.h"
#include "callstack.h"
#include "alien.h"
#include "quotations.h"
#include "factor.h"
#include "utilities.h"

#endif /* __FACTOR_MASTER_H__ */
