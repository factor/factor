#define USER_ENV 16

#define STDIN_ENV      0
#define STDOUT_ENV     1
#define STDERR_ENV     2
#define NAMESTACK_ENV  3 /* used by library only */
#define GLOBAL_ENV     4
#define BREAK_ENV      5
#define CATCHSTACK_ENV 6 /* used by library only */
#define CPU_ENV        7
#define BOOT_ENV       8
#define RUNQUEUE_ENV   9 /* used by library only */
#define ARGS_ENV       10

/* Profiling timer */
struct itimerval prof_timer;

/* Error handlers restore this */
sigjmp_buf toplevel;

/* TAGGED currently executing quotation */
CELL callframe;

/* raw pointer to datastack bottom */
CELL ds_bot;

/* raw pointer to datastack top */
#ifdef FACTOR_X86
register CELL ds asm("%esi");
#else
CELL ds;
#endif

/* raw pointer to callstack bottom */
CELL cs_bot;

/* raw pointer to callstack top */
CELL cs;

/* raw pointer to currently executing word */
WORD* executing;

/* TAGGED user environment data; see getenv/setenv prims */
CELL userenv[USER_ENV];

/* Call stack depth to start profile counter from */
/* This ensures that words in the user's interpreter do not count */
CELL profile_depth;

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

INLINE CELL cpeek(void)
{
	return get(cs);
}

INLINE void call(CELL quot)
{
	/* tail call optimization */
	if(callframe != F)
	{
		cpush(tag_word(executing));
		cpush(callframe);
	}
	callframe = quot;
}

void clear_environment(void);

void run(void);
void undefined(void);
void docol(void);
void dosym(void);
void primitive_execute(void);
void primitive_call(void);
void primitive_ifte(void);
void primitive_getenv(void);
void primitive_setenv(void);
