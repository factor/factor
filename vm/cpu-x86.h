#define FACTOR_CPU_STRING "x86.32"

register CELL ds asm("esi");
register CELL rs asm("edi");

#define FASTCALL __attribute__ ((regparm (2)))

typedef struct _F_STACK_FRAME
{
	/* In compiled quotation frames, position within the array.
	In compiled word frames, unused. */
	CELL scan;

	/* In compiled quotation frames, the quot->array slot.
	In compiled word frames, unused. */
	CELL array;

	/* In all compiled frames, the XT on entry. */
	XT xt;

	struct _F_STACK_FRAME *next;
} F_STACK_FRAME;

#define CALLSTACK_UP_P

#define FRAME_SUCCESSOR(frame) (frame)->next

INLINE void flush_icache(CELL start, CELL len) {}

void c_to_factor(CELL quot);

void set_callstack(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy);
void throw_impl(CELL quot, F_STACK_FRAME *rewind_to);

/* Defined in cpu-x86.S and only called from Factor-compiled code. They all
use funny calling convention. */
void undefined(CELL word);
void dosym(CELL word);
void docol_profiling(CELL word);
void docol(CELL word);
