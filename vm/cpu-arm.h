#define FACTOR_CPU_STRING "arm"

register CELL ds asm("r5");
register CELL rs asm("r6");

#define F_FASTCALL

typedef struct
{
	/* In compiled quotation frames, position within the array.
	In compiled word frames, unused. */
	CELL scan;

	/* In compiled quotation frames, the quot->array slot.
	In compiled word frames, unused. */
	CELL array;

	/* In all compiled frames, the XT on entry. */
	XT xt;

	/* Frame size in bytes */
	CELL size;
} F_STACK_FRAME;

#define FRAME_RETURN_ADDRESS(frame) *(XT *)(frame_successor(frame) + 1)

void c_to_factor(CELL quot);
void dosym(CELL word);
void docol_profiling(CELL word);
void docol(CELL word);
void undefined(CELL word);
void set_callstack(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy);
void throw_impl(CELL quot, F_STACK_FRAME *rewind);
void lazy_jit_compile(CELL quot);
