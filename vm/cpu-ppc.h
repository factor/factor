typedef struct _F_STACK_FRAME
{
	/* In compiled quotation frames, the quot->array slot.
	In compiled word frames, unused. */
	CELL array;

	/* In compiled quotation frames, position within the array.
	In compiled word frames, unused. */
	CELL scan;

	/* In all compiled frames, the XT on entry. */
	XT xt;

	/* Pointer to the next stack frame; frames are chained from
	the bottom on up */
	struct _F_STACK_FRAME *next;
} F_STACK_FRAME;

#define FACTOR_CPU_STRING "ppc"
#define F_FASTCALL

register CELL ds asm("r14");
register CELL rs asm("r15");

void c_to_factor(CELL quot);
void dosym(CELL word);
void docol_profiling(CELL word);
void docol(CELL word);
void undefined(CELL word);
void set_callstack(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy);
void throw_impl(CELL quot, F_STACK_FRAME *rewind);
void lazy_jit_compile(CELL quot);
void flush_icache(CELL start, CELL len);
