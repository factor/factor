#ifndef __FACTOR_H__
#define __FACTOR_H__

#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <math.h>
#include <setjmp.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <sys/time.h>
#include <netdb.h>

#define INLINE inline static

/* CELL must be 32 bits and your system must have 32-bit pointers */
typedef unsigned long int CELL;
#define CELLS ((signed)sizeof(CELL))

/* must always be 16 bits */
typedef unsigned short CHAR;
#define CHARS ((signed)sizeof(CHAR))

/* Memory heap size */
#define DEFAULT_ARENA (5 * 1024 * 1024)

#define STACK_SIZE 16384

/* This decreases performance slightly but gives more readable backtraces,
and allows profiling. */
#define FACTOR_PROFILER

#include "memory.h"
#include "error.h"
#include "gc.h"
#include "types.h"
#include "word.h"
#include "run.h"
#include "fixnum.h"
#include "array.h"
#include "s48_bignumint.h"
#include "s48_bignum.h"
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
#include "io.h"
#include "read.h"
#include "write.h"
#include "file.h"
#include "socket.h"
#include "cons.h"
#include "image.h"
#include "primitives.h"
#include "vector.h"
#include "stack.h"

#endif /* __FACTOR_H__ */
