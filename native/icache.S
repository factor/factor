/* Thanks to Joshua Grams for this code.

On PowerPC processors, we must flush the instruction cache manually
after writing to the code heap.

Callable from C as
void flush_icache(void *start, int len)

This function is called from compiler.c. */

#ifdef FACTOR_PPC

/* IN: 3 = start, 4 = len */

	.global _flush_icache
_flush_icache:
	/* compute number of cache lines to flush */
	add 4,4,3
	clrrwi 3,3,5    /* align addr to next lower cache line boundary */
	sub 4,4,3       /* then n_lines = (len + 0x1f) / 0x20 */
	addi 4,4,0x1f
	srwi. 4,4,5     /* note '.' suffix */
	beqlr           /* if n_lines == 0, just return. */
	mtctr 4         /* flush cache lines */
0:	dcbf 0,3        /* for each line... */
	sync
	icbi 0,3
	addi 3,3,0x20
	bdnz 0b
	sync            /* finish up */
	isync
	blr

#endif
