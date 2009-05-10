namespace factor
{

#define USER_ENV 70

enum special_object {
	NAMESTACK_ENV,            /* used by library only */
	CATCHSTACK_ENV,           /* used by library only, per-callback */

	CURRENT_CALLBACK_ENV = 2, /* used by library only, per-callback */
	WALKER_HOOK_ENV,          /* non-local exit hook, used by library only */
	CALLCC_1_ENV,             /* used to pass the value in callcc1 */

	BREAK_ENV            = 5, /* quotation called by throw primitive */
	ERROR_ENV,                /* a marker consed onto kernel errors */

	CELL_SIZE_ENV        = 7, /* sizeof(cell) */
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
	JIT_WORD_SPECIAL,
	JIT_IF_WORD,
	JIT_IF,
	JIT_EPILOG,
	JIT_RETURN,
	JIT_PROFILING,
	JIT_PUSH_IMMEDIATE,
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
	PIC_LOAD            = 47,
	PIC_TAG,
	PIC_HI_TAG,
	PIC_TUPLE,
	PIC_HI_TAG_TUPLE,
	PIC_CHECK_TAG,
	PIC_CHECK,
	PIC_HIT,
	PIC_MISS_WORD,
	PIC_MISS_TAIL_WORD,

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
};

#define FIRST_SAVE_ENV BOOT_ENV
#define LAST_SAVE_ENV STAGE2_ENV

inline static bool save_env_p(cell i)
{
	return (i >= FIRST_SAVE_ENV && i <= LAST_SAVE_ENV) || i == STACK_TRACES_ENV;
}

/* Canonical T object. It's just a word */
extern cell T;

PRIMITIVE(getenv);
PRIMITIVE(setenv);
PRIMITIVE(exit);
PRIMITIVE(micros);
PRIMITIVE(sleep);
PRIMITIVE(set_slot);
PRIMITIVE(load_locals);
PRIMITIVE(clone);

}

/* TAGGED user environment data; see getenv/setenv prims */
VM_C_API factor::cell userenv[USER_ENV];
