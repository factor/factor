/* Is profiling on? */
DLLEXPORT bool profiling;

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

XT default_word_xt(F_WORD *word);

DECLARE_PRIMITIVE(execute);
DECLARE_PRIMITIVE(call);
DECLARE_PRIMITIVE(uncurry);
DECLARE_PRIMITIVE(getenv);
DECLARE_PRIMITIVE(setenv);
DECLARE_PRIMITIVE(exit);
DECLARE_PRIMITIVE(os_env);
DECLARE_PRIMITIVE(eq);
DECLARE_PRIMITIVE(millis);
DECLARE_PRIMITIVE(sleep);
DECLARE_PRIMITIVE(type);
DECLARE_PRIMITIVE(tag);
DECLARE_PRIMITIVE(class_hash);
DECLARE_PRIMITIVE(slot);
DECLARE_PRIMITIVE(set_slot);

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
	ERROR_MEMORY,
	ERROR_NOT_IMPLEMENTED,
} F_ERRORTYPE;

void fatal_error(char* msg, CELL tagged);
void critical_error(char* msg, CELL tagged);
DECLARE_PRIMITIVE(die);

void throw_error(CELL error, F_STACK_FRAME *native_stack);
void general_error(F_ERRORTYPE error, CELL arg1, CELL arg2, F_STACK_FRAME *native_stack);
void divide_by_zero_error(F_STACK_FRAME *native_stack);
void memory_protection_error(CELL addr, F_STACK_FRAME *native_stack);
void signal_error(int signal, F_STACK_FRAME *native_stack);
void type_error(CELL type, CELL tagged);
void not_implemented_error(void);

F_FASTCALL void undefined_error(CELL word, F_STACK_FRAME *callstack_top);

DECLARE_PRIMITIVE(throw);

INLINE void type_check(CELL type, CELL tagged)
{
	if(type_of(tagged) != type) type_error(type,tagged);
}

DECLARE_PRIMITIVE(profiling);
