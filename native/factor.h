#ifndef __FACTOR_H__
#define __FACTOR_H__

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <math.h>
#include <setjmp.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <sys/time.h>

#define INLINE inline static

/* CELL must be 32 bits and your system must have 32-bit pointers */
typedef unsigned long int CELL;
#define CELLS sizeof(CELL)

/* must always be 16 bits */
typedef unsigned short CHAR;
#define CHARS sizeof(CHAR)

/* Memory heap size */
#define DEFAULT_ARENA (32 * 1024 * 1024)

#define STACK_SIZE 16384

#include "error.h"
#include "memory.h"
#include "gc.h"
#include "types.h"
#include "array.h"
#include "word.h"
#include "run.h"
#include "fixnum.h"
#include "bignum.h"
#include "ratio.h"
#include "float.h"
#include "complex.h"
#include "arithmetic.h"
#include "misc.h"
#include "relocate.h"
#include "string.h"
#include "sbuf.h"
#include "port.h"
#include "fd.h"
#include "file.h"
#include "socket.h"
#include "iomux.h"
#include "cons.h"
#include "image.h"
#include "primitives.h"
#include "vector.h"
#include "stack.h"

#endif /* __FACTOR_H__ */
