#ifndef __FACTOR_H__
#define __FACTOR_H__

#if defined(i386) || defined(__i386) || defined(__i386__) || defined(WIN32)
    #define FACTOR_X86
#endif

/* CELL must be 32 bits and your system must have 32-bit pointers */
typedef unsigned long int CELL;
#define CELLS ((signed)sizeof(CELL))

/* raw pointer to datastack bottom */
CELL ds_bot;

/* raw pointer to datastack top */
CELL ds;

/* raw pointer to callstack bottom */
CELL cs_bot;

/* raw pointer to callstack top */
CELL cs;

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <math.h>
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

#if defined(_MSC_VER)
	#pragma warning(disable:4312)
	#pragma warning(disable:4311)
	typedef enum { false, true } _Bool;
	typedef enum _Bool bool;
	typedef unsigned char uint8_t;
	typedef unsigned short uint16_t;
	typedef unsigned int uint32_t;
	typedef unsigned __int64 uint64_t;
	typedef signed char int8_t;
	typedef signed short int16_t;
	typedef signed int int32_t;
	typedef signed __int64 int64_t;
	#define snprintf _snprintf
#else
	#include <stdbool.h>
#endif

#ifdef FFI
#include <dlfcn.h>
#endif /* FFI */

#if defined(_MSC_VER)
	#define INLINE static __inline
#else
	#define INLINE inline static
#endif

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
#define DEFAULT_ARENA (64 * 1024 * 1024)
#define COMPILE_ZONE_SIZE (64 * 1024 * 1024)
#define STACK_SIZE (2 * 1024 * 1024)

#include "memory.h"
#include "error.h"
#include "types.h"
#include "gc.h"
#include "boolean.h"
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
