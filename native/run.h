#define USER_ENV 16

#define STDIN_ENV      0
#define STDOUT_ENV     1
#define STDERR_ENV     2
#define NAMESTACK_ENV  3
#define GLOBAL_ENV     4
#define BREAK_ENV      5
#define CATCHSTACK_ENV 6
#define GC_ENV         7

/* Error handlers restore this */
jmp_buf toplevel;

typedef struct {
	/* TAGGED top of datastack; EMPTY if datastack is empty */
	CELL dt;
	/* TAGGED currently executing quotation */
	CELL cf;
	/* TAGGED pointer to datastack bottom */
	CELL ds_bot;
	/* raw pointer to datastack top */
	CELL ds;
	/* TAGGED pointer to callstack bottom */
	CELL cs_bot;
	/* raw pointer to callstack top */
	CELL cs;
	/* raw pointer to currently executing word */
	WORD* w;
	/* TAGGED bootstrap quotation */
	CELL boot;
	/* TAGGED user environment data */
	CELL user[USER_ENV];
} ENV;

ENV env;

void clear_environment(void);
void init_environment(void);
void check_non_empty(CELL cell);

INLINE CELL dpop(void)
{
	env.ds -= CELLS;
	return get(env.ds);
}

INLINE void dpush(CELL top)
{
	put(env.ds,top);
	env.ds += CELLS;
}

INLINE CELL dpeek(void)
{
	return get(env.ds - CELLS);
}

INLINE CELL cpop(void)
{
	env.cs -= CELLS;
	return get(env.cs);
}

INLINE void cpush(CELL top)
{
	put(env.cs,top);
	env.cs += CELLS;
}

INLINE CELL cpeek(void)
{
	return get(env.cs - CELLS);
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
