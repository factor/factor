#define USER_ENV 16

#define CARD_OFF_ENV   1 /* for compiling set-slot */
#define UNUSED_ENV     2
#define NAMESTACK_ENV  3 /* used by library only */
#define GLOBAL_ENV     4
#define BREAK_ENV      5
#define CATCHSTACK_ENV 6 /* used by library only */
#define CPU_ENV        7
#define BOOT_ENV       8
#define RUNQUEUE_ENV   9 /* used by library only */
#define ARGS_ENV       10
#define OS_ENV         11
#define ERROR_ENV      12 /* a marker consed onto kernel errors */
#define IN_ENV         13
#define OUT_ENV        14
#define GEN_ENV        15 /* set to GC_GENERATIONS constant */

/* TAGGED user environment data; see getenv/setenv prims */
DLLEXPORT CELL userenv[USER_ENV];

/* Profiling timer */
#ifndef WIN32
struct itimerval prof_timer;
#endif

/* Error handlers restore this */
#ifdef WIN32
jmp_buf toplevel;
#else
sigjmp_buf toplevel;
#endif

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

INLINE void call(CELL quot)
{
	/* tail call optimization */
	if(callframe == F)
		/* put(cs - CELLS,executing) */;
	else
	{
		cpush(executing);
		cpush(callframe);
	}

	callframe = quot;
}

void run(void);
void platform_run(void);
void undefined(F_WORD* word);
void docol(F_WORD* word);
void dosym(F_WORD* word);
void primitive_execute(void);
void primitive_call(void);
void primitive_ifte(void);
void primitive_getenv(void);
void primitive_setenv(void);
