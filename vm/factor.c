#include "master.h"

void default_parameters(F_PARAMETERS *p)
{
	p->image = NULL;

	/* We make a wild guess here that if we're running on ARM, we don't
	have a lot of memory. */
#ifdef FACTOR_ARM
	p->ds_size = 8 * CELLS;
	p->rs_size = 8 * CELLS;

	p->gen_count = 2;
	p->code_size = 4;
	p->young_size = 1;
	p->aging_size = 1;
	p->tenured_size = 6;
#else
	p->ds_size = 32 * CELLS;
	p->rs_size = 32 * CELLS;

	p->gen_count = 3;
	p->code_size = 8 * CELLS;
	p->young_size = CELLS / 4;
	p->aging_size = CELLS / 2;
	p->tenured_size = 4 * CELLS;
#endif

	p->secure_gc = false;
	p->fep = false;

#ifdef WINDOWS
	p->console = false;
#else
	p->console = true;
#endif

	p->stack_traces = true;
}

/* Do some initialization that we do once only */
void do_stage1_init(void)
{
	print_string("*** Stage 2 early init... ");
	fflush(stdout);

	compile_all_words();
	userenv[STAGE2_ENV] = T;

	print_string("done\n");
	fflush(stdout);
}

/* Get things started */
void init_factor(F_PARAMETERS *p)
{
	/* Kilobytes */
	p->ds_size = align_page(p->ds_size << 10);
	p->rs_size = align_page(p->rs_size << 10);

	/* Megabytes */
	p->young_size <<= 20;
	p->aging_size <<= 20;
	p->tenured_size <<= 20;
	p->code_size <<= 20;

	/* Disable GC during init as a sanity check */
	gc_off = true;

	/* OS-specific initialization */
	early_init();

	if(p->image == NULL)
		p->image = default_image_path();

	srand(current_micros());
	init_ffi();
	init_stacks(p->ds_size,p->rs_size);
	load_image(p);
	init_c_io();
	init_signals();

	if(p->console)
		open_console();

	stack_chain = NULL;
	profiling_p = false;
	performing_gc = false;
	last_code_heap_scan = NURSERY;
	collecting_aging_again = false;

	userenv[CPU_ENV] = tag_object(from_char_string(FACTOR_CPU_STRING));
	userenv[OS_ENV] = tag_object(from_char_string(FACTOR_OS_STRING));
	userenv[CELL_SIZE_ENV] = tag_fixnum(sizeof(CELL));
	userenv[STACK_TRACES_ENV] = tag_boolean(p->stack_traces);

	/* We can GC now */
	gc_off = false;

	if(!stage2)
		do_stage1_init();
}

INLINE bool factor_arg(const F_CHAR* str, const F_CHAR* arg, CELL* value)
{
	int val;
	if(SSCANF(str,arg,&val) > 0)
	{
		*value = val;
		return true;
	}
	else
		return false;
}

void init_factor_from_args(F_CHAR *image, int argc, F_CHAR **argv, bool embedded)
{
	F_PARAMETERS p;
	default_parameters(&p);

	if(image) p.image = image;

	CELL i;

	posix_argc = argc;
	posix_argv = safe_malloc(argc * sizeof(F_CHAR*));
	posix_argv[0] = safe_strdup(argv[0]);

	for(i = 1; i < argc; i++)
	{
		posix_argv[i] = safe_strdup(argv[i]);
		if(factor_arg(argv[i],STR_FORMAT("-datastack=%d"),&p.ds_size));
		else if(factor_arg(argv[i],STR_FORMAT("-retainstack=%d"),&p.rs_size));
		else if(factor_arg(argv[i],STR_FORMAT("-generations=%d"),&p.gen_count));
		else if(factor_arg(argv[i],STR_FORMAT("-young=%d"),&p.young_size));
		else if(factor_arg(argv[i],STR_FORMAT("-aging=%d"),&p.aging_size));
		else if(factor_arg(argv[i],STR_FORMAT("-tenured=%d"),&p.tenured_size));
		else if(factor_arg(argv[i],STR_FORMAT("-codeheap=%d"),&p.code_size));
		else if(STRCMP(argv[i],STR_FORMAT("-securegc")) == 0)
			p.secure_gc = true;
		else if(STRCMP(argv[i],STR_FORMAT("-fep")) == 0)
			p.fep = true;
		else if(STRNCMP(argv[i],STR_FORMAT("-i="),3) == 0)
			p.image = argv[i] + 3;
		else if(STRCMP(argv[i],STR_FORMAT("-console")) == 0)
			p.console = true;
		else if(STRCMP(argv[i],STR_FORMAT("-no-stack-traces")) == 0)
			p.stack_traces = false;
	}

	init_factor(&p);
	nest_stacks();

	F_ARRAY *args = allot_array(ARRAY_TYPE,argc,F);

	for(i = 1; i < argc; i++)
	{
		REGISTER_UNTAGGED(args);
		CELL arg = tag_object(from_native_string(argv[i]));
		UNREGISTER_UNTAGGED(args);
		set_array_nth(args,i,arg);
	}

	userenv[ARGS_ENV] = tag_object(args);

	const F_CHAR *executable_path = vm_executable_path();
	if(!executable_path)
		executable_path = argv[0];

	userenv[EXECUTABLE_ENV] = tag_object(from_native_string(executable_path));
	userenv[EMBEDDED_ENV] = (embedded ? T : F);

	if(p.fep)
		factorbug();

	c_to_factor_toplevel(userenv[BOOT_ENV]);
	unnest_stacks();

	for(i = 0; i < argc; i++)
		free(posix_argv[i]);
	free(posix_argv);
}

char *factor_eval_string(char *string)
{
	char* (*callback)(char*) = alien_offset(userenv[EVAL_CALLBACK_ENV]);
	return callback(string);
}

void factor_eval_free(char *result)
{
	free(result);
}

void factor_yield(void)
{
	void (*callback)() = alien_offset(userenv[YIELD_CALLBACK_ENV]);
	callback();
}

void factor_sleep(long us)
{
	void (*callback)() = alien_offset(userenv[SLEEP_CALLBACK_ENV]);
	callback(us);
}
