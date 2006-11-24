/* Callstack top pointer */
CELL cs;

/* TAGGED currently executing quotation */
CELL callframe;

/* UNTAGGED currently executing word in quotation */
CELL callframe_scan;

/* UNTAGGED end of quotation */
CELL callframe_end;

#define USER_ENV 32

#define CELL_SIZE_ENV       1 /* sizeof(CELL) */
#define NLX_VECTOR_ENV      2 /* non-local exit hook, used by library only */
#define NAMESTACK_ENV       3 /* used by library only */
#define GLOBAL_ENV          4
#define BREAK_ENV           5
#define CATCHSTACK_ENV      6 /* used by library only */
#define CPU_ENV             7
#define BOOT_ENV            8
#define CALLCC_1_ENV        9 /* used by library only */
#define ARGS_ENV            10
#define OS_ENV              11
#define ERROR_ENV           12 /* a marker consed onto kernel errors */
#define IN_ENV              13
#define OUT_ENV             14
#define GEN_ENV             15 /* set to gen_count */
#define IMAGE_ENV           16 /* image name */
#define CODE_HEAP_START_ENV 17 /* start of code heap, used by :trace */
#define CODE_HEAP_END_ENV   18 /* end of code heap, used by :trace */

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

INLINE CELL align8(CELL a)
{
	return (a + 7) & ~7;
}

/* Canonical T object. It's just a word */
CELL T;

INLINE CELL tag_header(CELL cell)
{
	return RETAG(cell << TAG_BITS,OBJECT_TYPE);
}

INLINE CELL untag_header(CELL cell)
{
	/* if((cell & TAG_MASK) != OBJECT_TYPE)
		critical_error("Corrupt object header",cell); */

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

void call(CELL quot);

void handle_error();
void interpreter_loop(void);
void interpreter(void);
DLLEXPORT void run_callback(CELL quot);
void run(void);
void run_toplevel(void);
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
void primitive_type(void);
void primitive_tag(void);
void primitive_slot(void);
void primitive_set_slot(void);
void primitive_clone(void);

/* Runtime errors */
typedef enum
{
	ERROR_EXPIRED,
	ERROR_IO,
	ERROR_UNDEFINED_WORD,
	ERROR_TYPE,
	ERROR_SIGNAL,
	ERROR_NEGATIVE_ARRAY_SIZE,
	ERROR_C_STRING,
	ERROR_FFI,
	ERROR_HEAP_SCAN,
	ERROR_UNDEFINED_SYMBOL,
	ERROR_USER_INTERRUPT,
	ERROR_DS_UNDERFLOW,
	ERROR_DS_OVERFLOW,
	ERROR_RS_UNDERFLOW,
	ERROR_RS_OVERFLOW,
	ERROR_CS_UNDERFLOW,
	ERROR_CS_OVERFLOW,
	ERROR_MEMORY,
	ERROR_OBJECTIVE_C
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
void throw_error(CELL error, bool keep_stacks);
void early_error(CELL error);
void general_error(F_ERRORTYPE error, CELL arg1, CELL arg2, bool keep_stacks);
void memory_protection_error(CELL addr, int signal);
void signal_error(int signal);
void type_error(CELL type, CELL tagged);
void memory_error(void);
void primitive_throw(void);
void primitive_die(void);

INLINE void type_check(CELL type, CELL tagged)
{
	if(type_of(tagged) != type)
		type_error(type,tagged);
}
