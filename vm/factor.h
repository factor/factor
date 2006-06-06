#ifndef __FACTOR_H__
#define __FACTOR_H__

#include "platform.h"

#ifdef _WIN64
        typedef long long F_FIXNUM;
        typedef unsigned long long CELL;
#else
        typedef long F_FIXNUM;
        typedef unsigned long CELL;
#endif

#define CELLS ((signed)sizeof(CELL))

#define WORD_SIZE (CELLS*8)
#define HALF_WORD_SIZE (CELLS*4)
#define HALF_WORD_MASK (((unsigned long)1<<HALF_WORD_SIZE)-1)

#define FIXNUM_MAX (((F_FIXNUM)1 << (WORD_SIZE - TAG_BITS - 1)) - 1)
#define FIXNUM_MIN (-((F_FIXNUM)1 << (WORD_SIZE - TAG_BITS - 1)))

/* must always be 16 bits */
#define CHARS ((signed)sizeof(u16))

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
typedef signed char s8;
typedef signed short s16;
typedef signed int s32;
typedef signed long long s64;

CELL cs;

#if defined(FACTOR_X86)
	register CELL ds asm("esi");
	register CELL rs asm("ebx");
	CELL cards_offset;
#elif defined(FACTOR_PPC)
	register CELL ds asm("r14");
	register CELL rs asm("r15");
	register CELL cards_offset asm("r16");
#elif defined(FACTOR_AMD64)
        register CELL ds asm("r14");
        register CELL rs asm("r15");
	register CELL cards_offset asm("r13");
#else
	CELL ds;
	CELL rs;
	CELL cards_offset;
#endif

/* TAGGED currently executing quotation */
CELL callframe;

/* UNTAGGED currently executing word in quotation */
CELL callframe_scan;

/* UNTAGGED end of quotation */
CELL callframe_end;

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

#include "debug.h"
#include "error.h"
#include "cards.h"
#include "memory.h"
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

void usage(void);

void early_init(void);

const char *default_image_path(void);

#endif /* __FACTOR_H__ */
