#include "master.hpp"

namespace factor
{

factor_vm *vm;
unordered_map<THREADHANDLE, factor_vm*> thread_vms;

void init_globals()
{
	init_platform_globals();
}

void factor_vm::default_parameters(vm_parameters *p)
{
	p->image_path = NULL;

	/* We make a wild guess here that if we're running on ARM, we don't
	have a lot of memory. */
#ifdef FACTOR_ARM
	p->ds_size = 8 * sizeof(cell);
	p->rs_size = 8 * sizeof(cell);

	p->code_size = 4;
	p->young_size = 1;
	p->aging_size = 1;
	p->tenured_size = 6;
#else
	p->ds_size = 32 * sizeof(cell);
	p->rs_size = 32 * sizeof(cell);

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
	if (this == vm)
		p->console = true;
	else		
		p->console = false;
	
#endif

	p->stack_traces = true;
}

bool factor_vm::factor_arg(const vm_char* str, const vm_char* arg, cell* value)
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

void factor_vm::init_parameters_from_args(vm_parameters *p, int argc, vm_char **argv)
{
	default_parameters(p);
	p->executable_path = argv[0];

	int i = 0;

	for(i = 1; i < argc; i++)
	{
		if(factor_arg(argv[i],STRING_LITERAL("-datastack=%d"),&p->ds_size));
		else if(factor_arg(argv[i],STRING_LITERAL("-retainstack=%d"),&p->rs_size));
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
void factor_vm::do_stage1_init()
{
	print_string("*** Stage 2 early init... ");
	fflush(stdout);

	compile_all_words();
	userenv[STAGE2_ENV] = T;

	print_string("done\n");
	fflush(stdout);
}

void factor_vm::init_factor(vm_parameters *p)
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
void factor_vm::pass_args_to_factor(int argc, vm_char **argv)
{
	growable_array args(this);
	int i;

	for(i = 1; i < argc; i++){
		args.add(allot_alien(F,(cell)argv[i]));
	}

	args.trim();
	userenv[ARGS_ENV] = args.elements.value();
}

void factor_vm::start_factor(vm_parameters *p)
{
	if(p->fep) factorbug();

	nest_stacks();
	c_to_factor_toplevel(userenv[BOOT_ENV]);
	unnest_stacks();
}

char *factor_vm::factor_eval_string(char *string)
{
	char *(*callback)(char *) = (char *(*)(char *))alien_offset(userenv[EVAL_CALLBACK_ENV]);
	return callback(string);
}

void factor_vm::factor_eval_free(char *result)
{
	free(result);
}

void factor_vm::factor_yield()
{
	void (*callback)() = (void (*)())alien_offset(userenv[YIELD_CALLBACK_ENV]);
	callback();
}

void factor_vm::factor_sleep(long us)
{
	void (*callback)(long) = (void (*)(long))alien_offset(userenv[SLEEP_CALLBACK_ENV]);
	callback(us);
}

void factor_vm::start_standalone_factor(int argc, vm_char **argv)
{
	vm_parameters p;
	default_parameters(&p);
	init_parameters_from_args(&p,argc,argv);
	init_factor(&p);
	pass_args_to_factor(argc,argv);
	start_factor(&p);
}

struct startargs {
	int argc;
	vm_char **argv;
};

factor_vm *new_factor_vm()
{
	factor_vm *newvm = new factor_vm();
	register_vm_with_thread(newvm);
	thread_vms[thread_id()] = newvm;

	return newvm;
}

// arg must be new'ed because we're going to delete it!
void* start_standalone_factor_thread(void *arg) 
{
	factor_vm *newvm = new_factor_vm();
	startargs *args = (startargs*) arg;
	int argc = args->argc; vm_char **argv = args->argv;
	delete args;
	newvm->start_standalone_factor(argc, argv);
	return 0;
}

VM_C_API void start_standalone_factor(int argc, vm_char **argv)
{
	factor_vm *newvm = new_factor_vm();
	vm = newvm;
	return newvm->start_standalone_factor(argc,argv);
}

VM_C_API THREADHANDLE start_standalone_factor_in_new_thread(int argc, vm_char **argv)
{
	startargs *args = new startargs;
	args->argc = argc; args->argv = argv; 
	return start_thread(start_standalone_factor_thread,args);
}

}
