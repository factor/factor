#ifndef __FACTOR_H__
#define __FACTOR_H__

#include <errno.h>
#include <setjmp.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INLINE inline static

/* CELL must be 32 bits and your system must have 32-bit pointers */
#define CELL unsigned int
#define CELLS sizeof(CELL)

/* must always be 16 bits */
#define CHAR unsigned short
#define CHARS sizeof(CHAR)

/* Memory heap size */
#define DEFAULT_ARENA (4 * 1024 * 1024)
#define STACK_SIZE 256

#include "error.h"
#include "memory.h"
#include "gc.h"
#include "types.h"
#include "array.h"
#include "fixnum.h"
#include "cons.h"
#include "word.h"
#include "run.h"
#include "handle.h"
#include "image.h"
#include "io.h"
#include "primitives.h"
#include "vector.h"
#include "stack.h"
#include "string.h"
#include "sbuf.h"
#include "relocate.h"

#endif /* __FACTOR_H__ */
