#include "master.hpp"

namespace factor
{

VM_C_API void default_parameters(vm_parameters *p)
{
	p->image_path = NULL;

	/* We make a wild guess here that if we're running on ARM, we don't
	have a lot of memory. */
#ifdef FACTOR_ARM
	p->ds_size = 8 * sizeof(cell);
	p->rs_size = 8 * sizeof(cell);

	p->gen_count = 2;
	p->code_size = 4;
	p->young_size = 1;
	p->aging_size = 1;
	p->tenured_size = 6;
#else
	p->ds_size = 32 * sizeof(cell);
	p->rs_size = 32 * sizeof(cell);

	p->gen_count = 3;
	p->code_size = 8 * sizeof(cell);
	p->young_size = sizeof(cell) / 4;
	p->aging_size = sizeof(cell) / 2;
	p->tenured_size = 4 * sizeof(cell);
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

static bool factor_arg(const vm_char* str, const vm_char* arg, cell* value)
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

VM_C_API void init_parameters_from_args(vm_parameters *p, int argc, vm_char **argv)
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
static void do_stage1_init()
{
	print_string("*** Stage 2 early init... ");
	fflush(stdout);

	compile_all_words();
	userenv[STAGE2_ENV] = T;

	print_string("done\n");
	fflush(stdout);
}

VM_C_API void init_factor(vm_parameters *p)
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

	const vm_char *executable_path = vm_executable_path();

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
	init_signals();

	if(p->console)
		open_console();

	init_profiler();

	userenv[CPU_ENV] = allot_alien(F,(cell)FACTOR_CPU_STRING);
	userenv[OS_ENV] = allot_alien(F,(cell)FACTOR_OS_STRING);
	userenv[CELL_SIZE_ENV] = tag_fixnum(sizeof(cell));
	userenv[EXECUTABLE_ENV] = allot_alien(F,(cell)p->executable_path);
	userenv[ARGS_ENV] = F;
	userenv[EMBEDDED_ENV] = F;

	/* We can GC now */
	gc_off = false;

	if(userenv[STAGE2_ENV] == F)
	{
		userenv[STACK_TRACES_ENV] = tag_boolean(p->stack_traces);
		do_stage1_init();
	}
}

/* May allocate memory */
VM_C_API void pass_args_to_factor(int argc, vm_char **argv)
{
	growable_array args;
	int i;

	for(i = 1; i < argc; i++)
		args.add(allot_alien(F,(cell)argv[i]));

	args.trim();
	userenv[ARGS_ENV] = args.elements.value();
}

static void start_factor(vm_parameters *p)
{
	if(p->fep) factorbug();

	nest_stacks();
	c_to_factor_toplevel(userenv[BOOT_ENV]);
	unnest_stacks();
}

VM_C_API void start_embedded_factor(vm_parameters *p)
{
	userenv[EMBEDDED_ENV] = T;
	start_factor(p);
}

VM_C_API void start_standalone_factor(int argc, vm_char **argv)
{
	vm_parameters p;
	default_parameters(&p);
	init_parameters_from_args(&p,argc,argv);
	init_factor(&p);
	pass_args_to_factor(argc,argv);
	start_factor(&p);
}

VM_C_API char *factor_eval_string(char *string)
{
	char *(*callback)(char *) = (char *(*)(char *))alien_offset(userenv[EVAL_CALLBACK_ENV]);
	return callback(string);
}

VM_C_API void factor_eval_free(char *result)
{
	free(result);
}

VM_C_API void factor_yield()
{
	void (*callback)() = (void (*)())alien_offset(userenv[YIELD_CALLBACK_ENV]);
	callback();
}

VM_C_API void factor_sleep(long us)
{
	void (*callback)(long) = (void (*)(long))alien_offset(userenv[SLEEP_CALLBACK_ENV]);
	callback(us);
}

}
