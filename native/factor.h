#ifndef __FACTOR_H__
#define __FACTOR_H__

#if defined(i386) || defined(__i386) || defined(__i386__) || defined(WIN32)
    #define FACTOR_X86
#endif

#if defined(WIN32)
	#define DLLEXPORT __declspec(dllexport)
#else
	#define DLLEXPORT
#endif

/* CELL must be 32 bits and your system must have 32-bit pointers */
typedef unsigned long int CELL;
#define CELLS ((signed)sizeof(CELL))

/* raw pointer to datastack bottom */
CELL ds_bot;

/* raw pointer to datastack top */
DLLEXPORT CELL ds;

/* raw pointer to callstack bottom */
CELL cs_bot;

/* raw pointer to callstack top */
DLLEXPORT CELL cs;

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <math.h>
#include <stdbool.h>
#include <setjmp.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifdef WIN32
	#include <windows.h>

	/* Difference between Jan 1 00:00:00 1601 and Jan 1 00:00:00 1970 */
	#define EPOCH_OFFSET 0x019db1ded53e8000LL
#else
	#include <dirent.h>
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
#endif

#if defined(FFI) && !defined(WIN32)
#include <dlfcn.h>
#endif /* FFI */

#define INLINE inline static

#define FIXNUM_MAX (LONG_MAX >> TAG_BITS)
#define FIXNUM_MIN (LONG_MIN >> TAG_BITS)

#define F_FIXNUM long int /* unboxed */

#define WORD_SIZE (CELLS*8)
#define HALF_WORD_SIZE (CELLS*4)
#define HALF_WORD_MASK (((unsigned long)1<<HALF_WORD_SIZE)-1)

/* must always be 16 bits */
#define CHARS ((signed)sizeof(uint16_t))

/* must always be 8 bits */
typedef unsigned char BYTE;

/* Memory areas */
#define DEFAULT_ARENA (16 * 1024 * 1024)
#define COMPILE_ZONE_SIZE (8 * 1024 * 1024)
#define STACK_SIZE (2 * 1024 * 1024)

#include "memory.h"
#include "error.h"
#include "types.h"
#include "gc.h"
#include "boolean.h"
#include "word.h"
#include "run.h"
#include "signal.h"
#include "cons.h"
#include "fixnum.h"
#include "array.h"
#include "s48_bignumint.h"
#include "s48_bignum.h"
#include "bignum.h"
#include "ratio.h"
#include "float.h"
#include "complex.h"
#include "arithmetic.h"
#include "string.h"
#include "misc.h"
#include "sbuf.h"
#include "port.h"
#include "io.h"
#include "read.h"
#include "write.h"
#include "file.h"
#include "socket.h"
#include "image.h"
#include "primitives.h"
#include "vector.h"
#include "hashtable.h"
#include "stack.h"
#include "compiler.h"
#include "relocate.h"
#include "ffi.h"
#include "debug.h"

#endif /* __FACTOR_H__ */
