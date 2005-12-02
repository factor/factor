#ifndef __FACTOR_H__
#define __FACTOR_H__

#include "platform.h"

#define FIXNUM_MAX (LONG_MAX >> TAG_BITS)
#define FIXNUM_MIN (LONG_MIN >> TAG_BITS)

#define F_FIXNUM long int /* unboxed */

#define WORD_SIZE (CELLS*8)
#define HALF_WORD_SIZE (CELLS*4)
#define HALF_WORD_MASK (((unsigned long)1<<HALF_WORD_SIZE)-1)

/* must always be 16 bits */
#define CHARS ((signed)sizeof(u16))

typedef unsigned long int CELL;
#define CELLS ((signed)sizeof(CELL))

typedef unsigned char u8; 	 
typedef unsigned short u16; 	 
typedef unsigned int u32; 	 
typedef unsigned long long u64; 	 
typedef signed char s8; 	 
typedef signed short s16; 	 
typedef signed int s32; 	 
typedef signed long long s64;

/* must always be 8 bits */
typedef unsigned char BYTE;

/* raw pointer to datastack bottom */
CELL ds_bot;

/* raw pointer to datastack top */
#if defined(FACTOR_X86)
	register CELL ds asm("esi");
#elif defined(FACTOR_PPC)
	register CELL ds asm("r14");
#elif defined(FACTOR_AMD64)
        register CELL ds asm("r12");
#else
	CELL ds;
#endif

/* raw pointer to callstack bottom */
CELL cs_bot;

/* raw pointer to callstack top */
#if defined(FACTOR_X86)
	register CELL cs asm("ebx");
#elif defined(FACTOR_PPC)
	register CELL cs asm("r15");
#elif defined(FACTOR_AMD64)
        register CELL cs asm("r13");
#else
	CELL cs;
#endif

/* TAGGED currently executing quotation */
CELL callframe;

/* TAGGED pointer to currently executing word */
CELL executing;

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

#ifdef FACTOR_SDL
#include "SDL/SDL.h"
#endif

#include <sys/param.h>

#ifdef WIN32
	#include <windows.h>
	#include <ctype.h>

	/* Difference between Jan 1 00:00:00 1601 and Jan 1 00:00:00 1970 */
	#define EPOCH_OFFSET 0x019db1ded53e8000LL
#else
	#include <dirent.h>
	#include <sys/mman.h>
	#include <sys/types.h>
	#include <sys/stat.h>
	#include <unistd.h>
	#include <sys/time.h>
    #include <dlfcn.h>
#endif

#include "error.h"
#include "cards.h"
#include "memory.h"
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
#include "string.h"
#include "misc.h"
#include "sbuf.h"
#include "io.h"
#include "file.h"
#include "image.h"
#include "primitives.h"
#include "vector.h"
#include "hashtable.h"
#include "stack.h"
#include "compiler.h"
#include "relocate.h"
#include "alien.h"
#include "dll.h"
#include "wrapper.h"
#include "debug.h"

#endif /* __FACTOR_H__ */
