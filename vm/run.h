/* Callstack top pointer */
CELL cs;

/* TAGGED currently executing quotation */
CELL callframe;

/* UNTAGGED currently executing word in quotation */
CELL callframe_scan;

/* UNTAGGED end of quotation */
CELL callframe_end;

#define USER_ENV 32

#define CARD_OFF_ENV      1 /* for compiling set-slot */
#define NLX_VECTOR_ENV    2 /* non-local exit hook */
#define NAMESTACK_ENV     3 /* used by library only */
#define GLOBAL_ENV        4
#define BREAK_ENV         5
#define CATCHSTACK_ENV    6 /* used by library only */
#define CPU_ENV           7
#define BOOT_ENV          8
#define CALLCC_1_ENV      9 /* used by library only */
#define ARGS_ENV          10
#define OS_ENV            11
#define ERROR_ENV         12 /* a marker consed onto kernel errors */
#define IN_ENV            13
#define OUT_ENV           14
#define GEN_ENV           15 /* set to gen_count */
#define IMAGE_ENV         16 /* image name */
#define CELL_SIZE_ENV     17 /* sizeof(CELL) */

/* TAGGED user environment data; see getenv/setenv prims */
DLLEXPORT CELL userenv[USER_ENV];

void call(CELL quot);

void handle_error();
void run(void);
void run_toplevel(void);
DLLEXPORT void run_callback(CELL quot);
void platform_run(void);
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
	ERROR_OBJECTIVE_C
} F_ERRORTYPE;

/* Are we throwing an error? */
bool throwing;
/* When throw_error throws an error, it sets this global and
longjmps back to the top-level. */
CELL thrown_error;
CELL thrown_keep_stacks;
/* Since longjmp restores registers, we must save all these values. */
CELL thrown_ds;
CELL thrown_rs;

void fatal_error(char* msg, CELL tagged);
void critical_error(char* msg, CELL tagged);
void throw_error(CELL error, bool keep_stacks);
void early_error(CELL error);
void general_error(F_ERRORTYPE error, CELL arg1, CELL arg2, bool keep_stacks);
void memory_protection_error(void *addr, int signal);
void signal_error(int signal);
void type_error(CELL type, CELL tagged);
void primitive_throw(void);
void primitive_die(void);
