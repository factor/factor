#include "master.h"

void default_parameters(F_PARAMETERS *p)
{
	p->image_path = NULL;

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

	p->max_pic_size = 3;

	p->secure_gc = false;
	p->fep = false;

#ifdef WINDOWS
	p->console = false;
#else
	p->console = true;
#endif

	p->stack_traces = true;
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

void init_parameters_from_args(F_PARAMETERS *p, int argc, F_CHAR **argv)
{
	default_parameters(p);
	p->executable_path = argv[0];

	int i = 0;

	for(i = 1; i < argc; i++)
	{
		if(factor_arg(argv[i],STRING_LITERAL("-datastack=%d"),&p->ds_size));
		else if(factor_arg(argv[i],STRING_LITERAL("-retainstack=%d"),&p->rs_size));
		else if(factor_arg(argv[i],STRING_LITERAL("-generations=%d"),&p->gen_count));
		else if(factor_arg(argv[i],STRING_LITERAL("-young=%d"),&p->young_size));
		else if(factor_arg(argv[i],STRING_LITERAL("-aging=%d"),&p->aging_size));
		else if(factor_arg(argv[i],STRING_LITERAL("-tenured=%d"),&p->tenured_size));
		else if(factor_arg(argv[i],STRING_LITERAL("-codeheap=%d"),&p->code_size));
		else if(factor_arg(argv[i],STRING_LITERAL("-pic=%d"),&p->max_pic_size));
		else if(STRCMP(argv[i],STRING_LITERAL("-securegc")) == 0) p->secure_gc = true;
		else if(STRCMP(argv[i],STRING_LITERAL("-fep")) == 0) p->fep = true;
		else if(STRNCMP(argv[i],STRING_LITERAL("-i="),3) == 0) p->image_path = argv[i] + 3;
		else if(STRCMP(argv[i],STRING_LITERAL("-console")) == 0) p->console = true;
		else if(STRCMP(argv[i],STRING_LITERAL("-no-stack-traces")) == 0) p->stack_traces = false;
	}
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

	const F_CHAR *executable_path = vm_executable_path();

	if(executable_path)
		p->executable_path = executable_path;

	if(p->image_path == NULL)
		p->image_path = default_image_path();

	srand(current_micros());
	init_ffi();
	init_stacks(p->ds_size,p->rs_size);
	load_image(p);
	init_c_io();
	init_inline_caching(p->max_pic_size);

#ifndef FACTOR_DEBUG
	init_signals();
#endif

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
	userenv[EXECUTABLE_ENV] = (p->executable_path ? tag_object(from_native_string(p->executable_path)) : F);
	userenv[ARGS_ENV] = F;
	userenv[EMBEDDED_ENV] = F;

	/* We can GC now */
	gc_off = false;

	if(!stage2)
	{
		userenv[STACK_TRACES_ENV] = tag_boolean(p->stack_traces);
		do_stage1_init();
	}
}

/* May allocate memory */
void pass_args_to_factor(int argc, F_CHAR **argv)
{
	F_ARRAY *args = allot_array(ARRAY_TYPE,argc,F);
	int i;

	for(i = 1; i < argc; i++)
	{
		REGISTER_UNTAGGED(args);
		CELL arg = tag_object(from_native_string(argv[i]));
		UNREGISTER_UNTAGGED(args);
		set_array_nth(args,i,arg);
	}

	userenv[ARGS_ENV] = tag_array(args);
}

void start_factor(F_PARAMETERS *p)
{
	if(p->fep) factorbug();

	nest_stacks();
	c_to_factor_toplevel(userenv[BOOT_ENV]);
	unnest_stacks();
}

void start_embedded_factor(F_PARAMETERS *p)
{
	userenv[EMBEDDED_ENV] = T;
	start_factor(p);
}

void start_standalone_factor(int argc, F_CHAR **argv)
{
	F_PARAMETERS p;
	default_parameters(&p);
	init_parameters_from_args(&p,argc,argv);
	init_factor(&p);
	pass_args_to_factor(argc,argv);
	start_factor(&p);
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
