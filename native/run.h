#define USER_ENV 16

#define STDIN_ENV      0
#define STDOUT_ENV     1
#define STDERR_ENV     2
#define NAMESTACK_ENV  3 /* used by library only */
#define GLOBAL_ENV     4
#define BREAK_ENV      5
#define CATCHSTACK_ENV 6 /* used by library only */
#define GC_ENV         7
#define BOOT_ENV       8
#define RUNQUEUE_ENV   9 /* used by library only */

/* Error handlers restore this */
sigjmp_buf toplevel;

/* TAGGED currently executing quotation */
CELL callframe;

/* raw pointer to datastack bottom */
CELL ds_bot;

/* raw pointer to datastack top */
CELL ds;

/* raw pointer to callstack bottom */
CELL cs_bot;

/* raw pointer to callstack top */
CELL cs;

/* raw pointer to currently executing word */
WORD* executing;

/* TAGGED user environment data; see getenv/setenv prims */
CELL userenv[USER_ENV];

void init_signals(void);

void clear_environment(void);

INLINE CELL dpop(void)
{
	ds -= CELLS;
	return get(ds);
}

INLINE void drepl(CELL top)
{
	put(ds - CELLS,top);
}

INLINE void dpush(CELL top)
{
	put(ds,top);
	ds += CELLS;
}

INLINE CELL dpeek(void)
{
	return get(ds - CELLS);
}

INLINE CELL cpop(void)
{
	cs -= CELLS;
	return get(cs);
}

INLINE void cpush(CELL top)
{
	put(cs,top);
	cs += CELLS;
}

INLINE CELL cpeek(void)
{
	return get(cs - CELLS);
}

void run(void);
void undefined(void);
void call(void);
void primitive_execute(void);
void primitive_call(void);
void primitive_ifte(void);
void primitive_getenv(void);
void primitive_setenv(void);
void primitive_exit(void);
void primitive_os_env(void);
