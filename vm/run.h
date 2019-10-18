/* Is profiling on? */
DLLEXPORT bool profiling;

/* Callstack top pointer */
F_INTERP_FRAME *cs;

/* Currently executing quotation */
F_INTERP_FRAME callframe;

#define USER_ENV 32

typedef enum {
	CURRENT_CALLBACK_ENV,   /* used by library only, per-callback */
	CELL_SIZE_ENV,          /* sizeof(CELL) */
	NLX_VECTOR_ENV,         /* non-local exit hook, used by library only */
	NAMESTACK_ENV,          /* used by library only */
	GLOBAL_ENV,             
	BREAK_ENV,              
	CATCHSTACK_ENV,         /* used by library only, per-callback */
	CPU_ENV,                
	BOOT_ENV,               
	CALLCC_1_ENV,           /* used by library only */
	ARGS_ENV,               
	OS_ENV,                 
	ERROR_ENV,              /* a marker consed onto kernel errors */
	IN_ENV,                 
	OUT_ENV,                
	EVAL_CALLBACK_ENV,      /* used when Factor is embedded in a C app */
	IMAGE_ENV,              /* image path name */
	EXECUTABLE_ENV,		/* runtime executable path name */
	YIELD_CALLBACK_ENV,     /* used when Factor is embedded in a C app */
	EMBEDDED_ENV,		/* are we embedded in another app? */
	SLEEP_CALLBACK_ENV,     /* used when Factor is embedded in a C app */
} F_ENVTYPE;

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
	return RETAG(cell << TAG_BITS,OBJECT_TYPE);
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
	if(tagged == F)
		return F_TYPE;
	else if(TAG(tagged) == FIXNUM_TYPE)
		return FIXNUM_TYPE;
	else
		return object_type(tagged);
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

void init_interpreter(void);

void call(CELL quot);
void handle_error();
void interpreter_loop(void);
void interpreter(void);
void run(void);
DLLEXPORT void run_toplevel(void);
void undefined(F_WORD *word);
void docol(F_WORD *word);
void dosym(F_WORD *word);
void primitive_execute(void);
void primitive_call(void);
void primitive_ifte(void);
void primitive_dispatch(void);
void primitive_getenv(void);
void primitive_setenv(void);
void primitive_exit(void);
void primitive_os_env(void);
void primitive_eq(void);
void primitive_millis(void);
void primitive_sleep(void);
void primitive_type(void);
void primitive_tag(void);
void primitive_class_hash(void);
void primitive_slot(void);
void primitive_set_slot(void);

DLLEXPORT void run_callback(CELL quot);

/* Runtime errors */
typedef enum
{
	ERROR_EXPIRED = 0,
	ERROR_IO,
	ERROR_UNDEFINED_WORD,
	ERROR_TYPE,
	ERROR_DIVIDE_BY_ZERO,
	ERROR_SIGNAL,
	ERROR_ARRAY_SIZE,
	ERROR_C_STRING,
	ERROR_FFI,
	ERROR_HEAP_SCAN,
	ERROR_UNDEFINED_SYMBOL,
	ERROR_DS_UNDERFLOW,
	ERROR_DS_OVERFLOW,
	ERROR_RS_UNDERFLOW,
	ERROR_RS_OVERFLOW,
	ERROR_CS_UNDERFLOW,
	ERROR_CS_OVERFLOW,
	ERROR_MEMORY,
	ERROR_OBJECTIVE_C,
	ERROR_PRIMITIVE
} F_ERRORTYPE;

/* Are we throwing an error? */
/* XXX Why is this volatile? The resulting executable crashes when compiled
under gcc on windows otherwise. Proper fix pending */
volatile bool throwing;
/* When throw_error throws an error, it sets this global and
longjmps back to the top-level. */
CELL thrown_error;
CELL thrown_native_stack_trace;
CELL thrown_keep_stacks;
/* Since longjmp restores registers, we must save all these values. */
CELL thrown_ds;
CELL thrown_rs;

void fatal_error(char* msg, CELL tagged);
void critical_error(char* msg, CELL tagged);
void throw_error(CELL error, bool keep_stacks, F_COMPILED_FRAME *native_stack);
void early_error(CELL error);
void general_error(F_ERRORTYPE error, CELL arg1, CELL arg2,
	bool keep_stacks, F_COMPILED_FRAME *native_stack);
void simple_error(F_ERRORTYPE error, CELL arg1, CELL arg2);
void memory_protection_error(CELL addr, F_COMPILED_FRAME *native_stacks);
void signal_error(int signal, F_COMPILED_FRAME *native_stack);
void type_error(CELL type, CELL tagged);
void divide_by_zero_error(void);
void primitive_error(void);
void primitive_throw(void);
void primitive_die(void);

INLINE void type_check(CELL type, CELL tagged)
{
	if(type_of(tagged) != type) type_error(type,tagged);
}

void primitive_profiling(void);
