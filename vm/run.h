#define USER_ENV 40

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
	IN_ENV,                   /* stdin FILE* handle */
	OUT_ENV,                  /* stdout FILE* handle */
                                  
	IMAGE_ENV           = 13, /* image path name */
	EXECUTABLE_ENV,		  /* runtime executable path name */
                                  
	EMBEDDED_ENV 	    = 15, /* are we embedded in another app? */
	EVAL_CALLBACK_ENV,        /* used when Factor is embedded in a C app */
	YIELD_CALLBACK_ENV,       /* used when Factor is embedded in a C app */
	SLEEP_CALLBACK_ENV,       /* used when Factor is embedded in a C app */

	COCOA_EXCEPTION_ENV = 19, /* Cocoa exception handler quotation */

	BOOT_ENV            = 20, /* boot quotation */
	GLOBAL_ENV,               /* global namespace */

	/* Used by the JIT compiler */
	JIT_CODE_FORMAT     = 22,
	JIT_SETUP,
	JIT_PROLOG,
	JIT_WORD_PRIMITIVE_JUMP,
	JIT_WORD_PRIMITIVE_CALL,
	JIT_WORD_JUMP,
	JIT_WORD_CALL,
	JIT_PUSH_WRAPPER,
	JIT_PUSH_LITERAL,
	JIT_IF_WORD,
	JIT_IF_JUMP,
	JIT_IF_CALL,
	JIT_DISPATCH_WORD,
	JIT_DISPATCH,
	JIT_EPILOG,
	JIT_RETURN,

	/* Profiler support */    
	PROFILING_ENV       = 38, /* is the profiler on? */
	PROFILER_PROLOGUE_ENV     /* length of optimizing compiler's profiler prologue */
} F_ENVTYPE;

#define FIRST_SAVE_ENV BOOT_ENV

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

INLINE u16 cget(CELL where)
{
	return *((u16*)where);
}

INLINE void cput(CELL where, u16 what)
{
	*((u16*)where) = what;
}

INLINE CELL align(CELL a, CELL b)
{
	return (a + b) & ~b;
}

#define align8(a) align(a,7)
#define align_page(a) align(a,getpagesize() - 1)

/* Canonical T object. It's just a word */
CELL T;

INLINE CELL tag_header(CELL cell)
{
	return cell << TAG_BITS;
}

INLINE CELL untag_header(CELL cell)
{
	return cell >> TAG_BITS;
}

INLINE CELL tag_object(void* cell)
{
	return RETAG(cell,OBJECT_TYPE);
}

INLINE CELL object_type(CELL tagged)
{
	return untag_header(get(UNTAG(tagged)));
}

INLINE CELL type_of(CELL tagged)
{
	CELL tag = TAG(tagged);
	if(tag == OBJECT_TYPE)
		return object_type(tagged);
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

	/* saved extra_roots pointer on entry to callback */
	CELL extra_roots;

	struct _F_CONTEXT *next;
} F_CONTEXT;

DLLEXPORT F_CONTEXT *stack_chain;

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
DECLARE_PRIMITIVE(drop);
DECLARE_PRIMITIVE(2drop);
DECLARE_PRIMITIVE(3drop);
DECLARE_PRIMITIVE(dup);
DECLARE_PRIMITIVE(2dup);
DECLARE_PRIMITIVE(3dup);
DECLARE_PRIMITIVE(rot);
DECLARE_PRIMITIVE(_rot);
DECLARE_PRIMITIVE(dupd);
DECLARE_PRIMITIVE(swapd);
DECLARE_PRIMITIVE(nip);
DECLARE_PRIMITIVE(2nip);
DECLARE_PRIMITIVE(tuck);
DECLARE_PRIMITIVE(over);
DECLARE_PRIMITIVE(pick);
DECLARE_PRIMITIVE(swap);
DECLARE_PRIMITIVE(to_r);
DECLARE_PRIMITIVE(from_r);
DECLARE_PRIMITIVE(datastack);
DECLARE_PRIMITIVE(retainstack);

XT default_word_xt(F_WORD *word);

DECLARE_PRIMITIVE(execute);
DECLARE_PRIMITIVE(call);
DECLARE_PRIMITIVE(getenv);
DECLARE_PRIMITIVE(setenv);
DECLARE_PRIMITIVE(exit);
DECLARE_PRIMITIVE(os_env);
DECLARE_PRIMITIVE(os_envs);
DECLARE_PRIMITIVE(eq);
DECLARE_PRIMITIVE(millis);
DECLARE_PRIMITIVE(sleep);
DECLARE_PRIMITIVE(type);
DECLARE_PRIMITIVE(tag);
DECLARE_PRIMITIVE(class_hash);
DECLARE_PRIMITIVE(slot);
DECLARE_PRIMITIVE(set_slot);
