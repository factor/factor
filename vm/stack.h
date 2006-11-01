INLINE CELL dpop(void)
{
	CELL value = get(ds);
	ds -= CELLS;
	return value;
}

INLINE void drepl(CELL top)
{
	put(ds,top);
}

INLINE void dpush(CELL top)
{
	ds += CELLS;
	put(ds,top);
}

INLINE CELL dpeek(void)
{
	return get(ds);
}

INLINE CELL cpop(void)
{
	CELL value = get(cs);
	cs -= CELLS;
	return value;
}

INLINE void cpush(CELL top)
{
	cs += CELLS;
	put(cs,top);
}

INLINE CELL rpop(void)
{
	CELL value = get(rs);
	rs -= CELLS;
	return value;
}

INLINE void rpush(CELL top)
{
	rs += CELLS;
	put(rs,top);
}

typedef struct _F_STACKS {
	/* current datastack top pointer */
	CELL data;
	/* saved contents of ds register on entry to callback */
	CELL data_save;
	/* memory region holding current datastack */
	F_BOUNDED_BLOCK *data_region;
	/* current retain stack top pointer */
	CELL retain;
	/* saved contents of rs register on entry to callback */
	CELL retain_save;
	/* memory region holding current retain stack */
	F_BOUNDED_BLOCK *retain_region;
	/* current callstack top pointer */
	CELL call;
	/* saved contents of cs register on entry to callback */
	CELL call_save;
	/* memory region holding current callstack */
	F_BOUNDED_BLOCK *call_region;
	/* saved callframe on entry to callback */
	CELL callframe;
	CELL callframe_scan;
	CELL callframe_end;
	/* saved catchstack on entry to callback */
	CELL catch_save;
	/* saved cards_offset register on entry to callback */
	CELL cards_offset;
	/* error handler longjmp buffer */
	JMP_BUF toplevel;

	struct _F_STACKS *next;
} F_STACKS;

F_STACKS *stack_chain;

CELL ds_size, rs_size, cs_size;

#define ds_bot ((CELL)(stack_chain->data_region->start))
#define rs_bot ((CELL)(stack_chain->retain_region->start))
#define cs_bot ((CELL)(stack_chain->call_region->start))

#define STACK_UNDERFLOW(stack,region) ((stack) + CELLS < (region)->start)
#define STACK_OVERFLOW(stack,region) ((stack) + CELLS >= (region)->start + (region)->size)

void reset_datastack(void);
void reset_retainstack(void);
void reset_callstack(void);
void fix_stacks(void);
DLLEXPORT void save_stacks(void);
DLLEXPORT void nest_stacks(void);
DLLEXPORT void unnest_stacks(void);
void init_stacks(CELL ds_size, CELL rs_size, CELL cs_size);

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
void primitive_datastack(void);
void primitive_retainstack(void);
void primitive_callstack(void);
void primitive_set_datastack(void);
void primitive_set_retainstack(void);
void primitive_set_callstack(void);
