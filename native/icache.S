#include "platform.h"

/* Thanks to Joshua Grams for this code.

On PowerPC processors, we must flush the instruction cache manually
after writing to the code heap.

Callable from C as
void flush_icache(void *start, int len)

This function is called from compiler.c. */

#ifdef FACTOR_PPC

/* IN: 3 = start, 4 = len */

	.globl MANGLE(flush_icache)
MANGLE(flush_icache):
	/* compute number of cache lines to flush */
	add r4,r4,r3
	clrrwi r3,r3,5    /* align addr to next lower cache line boundary */
	sub r4,r4,r3      /* then n_lines = (len + 0x1f) / 0x20 */
	addi r4,r4,0x1f
	srwi. r4,r4,5     /* note '.' suffix */
	beqlr             /* if n_lines == 0, just return. */
	mtctr r4          /* flush cache lines */
0:	dcbf r0,r3        /* for each line... */
	sync
	icbi r0,r3
	addi r3,r3,0x20
	bdnz 0b
	sync              /* finish up */
	isync
	blr

#endif
