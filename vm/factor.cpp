#include "master.hpp"

namespace factor
{

void init_globals()
{
	init_mvm();
}

void factor_vm::default_parameters(vm_parameters *p)
{
	p->embedded_image = false;
	p->image_path = NULL;

	p->datastack_size = 32 * sizeof(cell);
	p->retainstack_size = 32 * sizeof(cell);

#if defined(FACTOR_PPC)
	p->callstack_size = 256 * sizeof(cell);
#else
	p->callstack_size = 128 * sizeof(cell);
#endif

	p->code_size = 64;
	p->young_size = sizeof(cell) / 4;
	p->aging_size = sizeof(cell) / 2;
	p->tenured_size = 24 * sizeof(cell);

	p->max_pic_size = 3;

	p->fep = false;
	p->signals = true;

#ifdef WINDOWS
	p->console = GetConsoleWindow() != NULL;
#else
	p->console = true;
#endif

	p->callback_size = 256;
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
		vm_char *arg = argv[i];
		if(STRCMP(arg,STRING_LITERAL("--")) == 0) break;
		else if(factor_arg(arg,STRING_LITERAL("-datastack=%d"),&p->datastack_size));
		else if(factor_arg(arg,STRING_LITERAL("-retainstack=%d"),&p->retainstack_size));
		else if(factor_arg(arg,STRING_LITERAL("-callstack=%d"),&p->callstack_size));
		else if(factor_arg(arg,STRING_LITERAL("-young=%d"),&p->young_size));
		else if(factor_arg(arg,STRING_LITERAL("-aging=%d"),&p->aging_size));
		else if(factor_arg(arg,STRING_LITERAL("-tenured=%d"),&p->tenured_size));
		else if(factor_arg(arg,STRING_LITERAL("-codeheap=%d"),&p->code_size));
		else if(factor_arg(arg,STRING_LITERAL("-pic=%d"),&p->max_pic_size));
		else if(factor_arg(arg,STRING_LITERAL("-callbacks=%d"),&p->callback_size));
		else if(STRCMP(arg,STRING_LITERAL("-fep")) == 0) p->fep = true;
		else if(STRCMP(arg,STRING_LITERAL("-nosignals")) == 0) p->signals = false;
		else if(STRNCMP(arg,STRING_LITERAL("-i="),3) == 0) p->image_path = arg + 3;
		else if(STRCMP(arg,STRING_LITERAL("-console")) == 0) p->console = true;
	}
}

/* Compile code in boot image so that we can execute the startup quotation */
/* Allocates memory */
void factor_vm::prepare_boot_image()
{
	std::cout << "*** Stage 2 early init... " << std::flush;

	compile_all_words();
	update_code_heap_words(true);
	initialize_all_quotations();
	special_objects[OBJ_STAGE2] = true_object;

	std::cout << "done" << std::endl;
}

void factor_vm::init_factor(vm_parameters *p)
{
	/* Kilobytes */
	p->datastack_size = align_page(p->datastack_size << 10);
	p->retainstack_size = align_page(p->retainstack_size << 10);
	p->callstack_size = align_page(p->callstack_size << 10);
	p->callback_size = align_page(p->callback_size << 10);

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
	{
		if (embedded_image_p())
		{
			p->embedded_image = true;
			p->image_path = p->executable_path;
		}
		else
			p->image_path = default_image_path();
	}

	srand((unsigned int)nano_count());
	init_ffi();
	init_contexts(p->datastack_size,p->retainstack_size,p->callstack_size);
	init_callbacks(p->callback_size);
	load_image(p);
	init_c_io();
	init_inline_caching((int)p->max_pic_size);
	special_objects[OBJ_CPU] = allot_alien(false_object,(cell)FACTOR_CPU_STRING);
	special_objects[OBJ_OS] = allot_alien(false_object,(cell)FACTOR_OS_STRING);
	special_objects[OBJ_CELL_SIZE] = tag_fixnum(sizeof(cell));
	special_objects[OBJ_EXECUTABLE] = allot_alien(false_object,(cell)p->executable_path);
	special_objects[OBJ_ARGS] = false_object;
	special_objects[OBJ_EMBEDDED] = false_object;
	special_objects[OBJ_VM_COMPILER] = allot_alien(false_object,(cell)FACTOR_COMPILER_VERSION);

	/* We can GC now */
	gc_off = false;

	if(!to_boolean(special_objects[OBJ_STAGE2]))
		prepare_boot_image();

	if(p->signals)
		init_signals();

	if(p->console)
		open_console();

}

/* May allocate memory */
void factor_vm::pass_args_to_factor(int argc, vm_char **argv)
{
	growable_array args(this);

	for(fixnum i = 1; i < argc; i++)
		args.add(allot_alien(false_object,(cell)argv[i]));

	args.trim();
	special_objects[OBJ_ARGS] = args.elements.value();
}

void factor_vm::start_factor(vm_parameters *p)
{
	if(p->fep) factorbug();

	c_to_factor_toplevel(special_objects[OBJ_STARTUP_QUOT]);
}

void factor_vm::stop_factor()
{
	c_to_factor_toplevel(special_objects[OBJ_SHUTDOWN_QUOT]);
}

char *factor_vm::factor_eval_string(char *string)
{
	void *func = alien_offset(special_objects[OBJ_EVAL_CALLBACK]);
	CODE_TO_FUNCTION_POINTER(func);
	return ((char *(*)(char *))func)(string);
}

void factor_vm::factor_eval_free(char *result)
{
	free(result);
}

void factor_vm::factor_yield()
{
	void *func = alien_offset(special_objects[OBJ_YIELD_CALLBACK]);
	CODE_TO_FUNCTION_POINTER(func);
	((void (*)())func)();
}

void factor_vm::factor_sleep(long us)
{
	void *func = alien_offset(special_objects[OBJ_SLEEP_CALLBACK]);
	CODE_TO_FUNCTION_POINTER(func);
	((void (*)(long))func)(us);
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

factor_vm *new_factor_vm()
{
	THREADHANDLE thread = thread_id();
	factor_vm *newvm = new factor_vm(thread);
	register_vm_with_thread(newvm);
	thread_vms[thread] = newvm;

	return newvm;
}

VM_C_API void start_standalone_factor(int argc, vm_char **argv)
{
	factor_vm *newvm = new_factor_vm();
	return newvm->start_standalone_factor(argc,argv);
}

}
