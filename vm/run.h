#define USER_ENV 70

typedef enum {
	NAMESTACK_ENV,            /* used by library only */
	CATCHSTACK_ENV,           /* used by library only, per-callback */

	CURRENT_CALLBACK_ENV = 2, /* used by library only, per-callback */
	WALKER_HOOK_ENV,          /* non-local exit hook, used by library only */
	CALLCC_1_ENV,             /* used to pass the value in callcc1 */

	BREAK_ENV            = 5, /* quotation called by throw primitive */
	ERROR_ENV,                /* a marker consed onto kernel errors */

	CELL_SIZE_ENV        = 7, /* sizeof(CELL) */
	CPU_ENV,                  /* CPU architecture */
	OS_ENV,                   /* operating system name */

	ARGS_ENV            = 10, /* command line arguments */
	STDIN_ENV,                /* stdin FILE* handle */
	STDOUT_ENV,               /* stdout FILE* handle */

	IMAGE_ENV           = 13, /* image path name */
	EXECUTABLE_ENV,		  /* runtime executable path name */

	EMBEDDED_ENV 	    = 15, /* are we embedded in another app? */
	EVAL_CALLBACK_ENV,        /* used when Factor is embedded in a C app */
	YIELD_CALLBACK_ENV,       /* used when Factor is embedded in a C app */
	SLEEP_CALLBACK_ENV,       /* used when Factor is embedded in a C app */

	COCOA_EXCEPTION_ENV = 19, /* Cocoa exception handler quotation */

	BOOT_ENV            = 20, /* boot quotation */
	GLOBAL_ENV,               /* global namespace */

	/* Quotation compilation in quotations.c */
	JIT_PROLOG          = 23,
	JIT_PRIMITIVE_WORD,
	JIT_PRIMITIVE,
	JIT_WORD_JUMP,
	JIT_WORD_CALL,
	JIT_IF_WORD,
	JIT_IF_1,
	JIT_IF_2,
	JIT_EPILOG          = 33,
	JIT_RETURN,
	JIT_PROFILING,
	JIT_PUSH_IMMEDIATE,
	JIT_SAVE_STACK = 38,
	JIT_DIP_WORD,
	JIT_DIP,
	JIT_2DIP_WORD,
	JIT_2DIP,
	JIT_3DIP_WORD,
	JIT_3DIP,
	JIT_EXECUTE_WORD,
	JIT_EXECUTE_JUMP,
	JIT_EXECUTE_CALL,

	/* Polymorphic inline cache generation in inline_cache.c */
	PIC_LOAD            = 48,
	PIC_TAG,
	PIC_HI_TAG,
	PIC_TUPLE,
	PIC_HI_TAG_TUPLE,
	PIC_CHECK_TAG,
	PIC_CHECK,
	PIC_HIT,
	PIC_MISS_WORD,

	/* Megamorphic cache generation in dispatch.c */
	MEGA_LOOKUP         = 57,
	MEGA_LOOKUP_WORD,
        MEGA_MISS_WORD,

	UNDEFINED_ENV       = 60, /* default quotation for undefined words */

	STDERR_ENV          = 61, /* stderr FILE* handle */

	STAGE2_ENV          = 62, /* have we bootstrapped? */

	CURRENT_THREAD_ENV  = 63,

	THREADS_ENV         = 64,
	RUN_QUEUE_ENV       = 65,
	SLEEP_QUEUE_ENV     = 66,

	STACK_TRACES_ENV    = 67,
} F_ENVTYPE;

#define FIRST_SAVE_ENV BOOT_ENV
#define LAST_SAVE_ENV STAGE2_ENV

/* TAGGED user environment data; see getenv/setenv prims */
DLLEXPORT CELL userenv[USER_ENV];

/* macros for reading/writing memory, useful when working around
C's type system */
INLINE CELL get(CELL where)
{
	return *((CELL*)where);
}

INLINE void put(CELL where, CELL what)
{
	*((CELL*)where) = what;
}

INLINE CELL cget(CELL where)
{
	return *((u16 *)where);
}

INLINE void cput(CELL where, CELL what)
{
	*((u16 *)where) = what;
}

INLINE CELL bget(CELL where)
{
	return *((u8 *)where);
}

INLINE void bput(CELL where, CELL what)
{
	*((u8 *)where) = what;
}

INLINE CELL align(CELL a, CELL b)
{
	return (a + (b-1)) & ~(b-1);
}

#define align8(a) align(a,8)
#define align_page(a) align(a,getpagesize())

/* Canonical T object. It's just a word */
CELL T;

INLINE CELL tag_header(CELL cell)
{
	return cell << TAG_BITS;
}

INLINE void check_header(CELL cell)
{
#ifdef FACTOR_DEBUG
	assert(TAG(cell) == FIXNUM_TYPE && untag_fixnum_fast(cell) < TYPE_COUNT);
#endif
}

INLINE CELL untag_header(CELL cell)
{
	check_header(cell);
	return cell >> TAG_BITS;
}

INLINE CELL hi_tag(CELL tagged)
{
	return untag_header(get(UNTAG(tagged)));
}

INLINE CELL tag_object(void *cell)
{
#ifdef FACTOR_DEBUG
	assert(hi_tag((CELL)cell) >= HEADER_TYPE);
#endif
	return RETAG(cell,OBJECT_TYPE);
}

INLINE CELL type_of(CELL tagged)
{
	CELL tag = TAG(tagged);
	if(tag == OBJECT_TYPE)
		return hi_tag(tagged);
	else
		return tag;
}

#define DEFPUSHPOP(prefix,ptr) \
	INLINE CELL prefix##pop(void) \
	{ \
		CELL value = get(ptr); \
		ptr -= CELLS; \
		return value; \
	} \
	INLINE void prefix##push(CELL tagged) \
	{ \
		ptr += CELLS; \
		put(ptr,tagged); \
	} \
	INLINE void prefix##repl(CELL tagged) \
	{ \
		put(ptr,tagged); \
	} \
	INLINE CELL prefix##peek() \
	{ \
		return get(ptr); \
	}

DEFPUSHPOP(d,ds)
DEFPUSHPOP(r,rs)

typedef struct {
	CELL start;
	CELL size;
	CELL end;
} F_SEGMENT;

/* Assembly code makes assumptions about the layout of this struct:
   - callstack_top field is 0
   - callstack_bottom field is 1
   - datastack field is 2
   - retainstack field is 3 */
typedef struct _F_CONTEXT {
	/* C stack pointer on entry */
	F_STACK_FRAME *callstack_top;
	F_STACK_FRAME *callstack_bottom;

	/* current datastack top pointer */
	CELL datastack;

	/* current retain stack top pointer */
	CELL retainstack;

	/* saved contents of ds register on entry to callback */
	CELL datastack_save;

	/* saved contents of rs register on entry to callback */
	CELL retainstack_save;

	/* memory region holding current datastack */
	F_SEGMENT *datastack_region;

	/* memory region holding current retain stack */
	F_SEGMENT *retainstack_region;

	/* saved userenv slots on entry to callback */
	CELL catchstack_save;
	CELL current_callback_save;

	struct _F_CONTEXT *next;
} F_CONTEXT;

DLLEXPORT F_CONTEXT *stack_chain;

F_CONTEXT *unused_contexts;

CELL ds_size, rs_size;

#define ds_bot (stack_chain->datastack_region->start)
#define ds_top (stack_chain->datastack_region->end)
#define rs_bot (stack_chain->retainstack_region->start)
#define rs_top (stack_chain->retainstack_region->end)

void reset_datastack(void);
void reset_retainstack(void);
void fix_stacks(void);
DLLEXPORT void save_stacks(void);
DLLEXPORT void nest_stacks(void);
DLLEXPORT void unnest_stacks(void);
void init_stacks(CELL ds_size, CELL rs_size);

void primitive_datastack(void);
void primitive_retainstack(void);
void primitive_set_datastack(void);
void primitive_set_retainstack(void);
void primitive_check_datastack(void);
void primitive_getenv(void);
void primitive_setenv(void);
void primitive_exit(void);
void primitive_micros(void);
void primitive_sleep(void);
void primitive_set_slot(void);
void primitive_load_locals(void);
void primitive_clone(void);

bool stage2;
