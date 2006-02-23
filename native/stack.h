typedef struct _STACKS {
	/* current datastack top pointer */
	CELL data;
	/* saved contents of ds register on entry to callback */
	CELL data_save;
	/* memory region holding current datastack */
	BOUNDED_BLOCK *data_region;
	/* current callstack top pointer */
	CELL call;
	/* saved contents of cs register on entry to callback */
	CELL call_save;
	/* memory region holding current callstack */
	BOUNDED_BLOCK *call_region;
	/* saved callframe on entry to callback */
	CELL callframe;
	/* saved catchstack on entry to callback */
	CELL catch_save;
	/* error handler longjmp buffer */
	JMP_BUF toplevel;

	struct _STACKS *next;
} STACKS;

STACKS *stack_chain;

CELL ds_size, cs_size;

#define ds_bot ((CELL)(stack_chain->data_region->start))
#define cs_bot ((CELL)(stack_chain->call_region->start))

#define STACK_UNDERFLOW(stack,region) ((stack) + CELLS < (region)->start)
#define STACK_OVERFLOW(stack,region) ((stack) + CELLS >= (region)->start + (region)->size)

void reset_datastack(void);
void reset_callstack(void);
void fix_stacks(void);
DLLEXPORT void save_stacks(void);
DLLEXPORT void nest_stacks(void);
DLLEXPORT void unnest_stacks(void);
void init_stacks(CELL ds_size, CELL cs_size);

void primitive_drop(void);
void primitive_2drop(void);
void primitive_3drop(void);
void primitive_dup(void);
void primitive_2dup(void);
void primitive_3dup(void);
void primitive_rot(void);
void primitive__rot(void);
void primitive_dupd(void);
void primitive_swapd(void);
void primitive_nip(void);
void primitive_2nip(void);
void primitive_tuck(void);
void primitive_over(void);
void primitive_pick(void);
void primitive_swap(void);
void primitive_to_r(void);
void primitive_from_r(void);
F_VECTOR* stack_to_vector(CELL bottom, CELL top);
void primitive_datastack(void);
void primitive_callstack(void);
CELL vector_to_stack(F_VECTOR* vector, CELL bottom);
void primitive_set_datastack(void);
void primitive_set_callstack(void);
