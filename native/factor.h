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

#ifdef FFI
#include <dlfcn.h>
#endif /* FFI */

#define INLINE inline static

/* CELL must be 32 bits and your system must have 32-bit pointers */
typedef unsigned long int CELL;
#define CELLS ((signed)sizeof(CELL))

#define FIXNUM_MAX (LONG_MAX >> TAG_BITS)
#define FIXNUM_MIN (LONG_MIN >> TAG_BITS)

#define FIXNUM long int /* unboxed */

#define WORD_SIZE (CELLS*8)
#define HALF_WORD_SIZE (CELLS*4)
#define HALF_WORD_MASK (((unsigned long)1<<HALF_WORD_SIZE)-1)

/* must always be 16 bits */
typedef unsigned short CHAR;
#define CHARS ((signed)sizeof(CHAR))

/* must always be 8 bits */
typedef unsigned char BYTE;

/* Memory areas */
#define DEFAULT_ARENA (64 * 1024 * 1024)
#define COMPILE_ZONE_SIZE (64 * 1024 * 1024)
#define STACK_SIZE (2 * 1024 * 1024)

#include "memory.h"
#include "error.h"
#include "gc.h"
#include "types.h"
#include "word.h"
#include "run.h"
#include "signal.h"
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
#include "compiler.h"
#include "ffi.h"

#endif /* __FACTOR_H__ */
