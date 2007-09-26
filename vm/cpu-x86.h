typedef struct _F_STACK_FRAME
{
	/* In compiled quotation frames, position within the array.
	In compiled word frames, unused. */
	CELL scan;

	/* In compiled quotation frames, the quot->array slot.
	In compiled word frames, unused. */
	CELL array;

	/* Pointer to the next stack frame; frames are chained from
	the bottom on up */
	struct _F_STACK_FRAME *next;

	/* In all compiled frames, the XT on entry. */
	XT xt;
} F_STACK_FRAME;

#define CALLSTACK_UP_P

#define FRAME_SUCCESSOR(frame) (frame)->next

INLINE void flush_icache(CELL start, CELL len) {}

F_FASTCALL void c_to_factor(CELL quot);
F_FASTCALL void throw_impl(CELL quot, F_STACK_FRAME *rewind_to);
F_FASTCALL void undefined(CELL word);
F_FASTCALL void dosym(CELL word);
F_FASTCALL void docol_profiling(CELL word);
F_FASTCALL void docol(CELL word);

void set_callstack(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy);
