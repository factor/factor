#include "master.h"

void default_parameters(F_PARAMETERS *p)
{
	p->image = NULL;
	p->ds_size = 128;
	p->rs_size = 128;
	p->cs_size = 128;
	p->gen_count = 2;
	p->young_size = 2 * CELLS;
	p->aging_size = 4 * CELLS;
	p->code_size = 2 * CELLS;
	p->secure_gc = false;
}

/* Get things started */
void init_factor(F_PARAMETERS *p)
{
	/* Kilobytes */
	p->ds_size = align_page(p->ds_size << 10);
	p->rs_size = align_page(p->rs_size << 10);
	p->cs_size = align_page(p->cs_size << 10);

	/* Megabytes */
	p->young_size <<= 20;
	p->aging_size <<= 20;
	p->code_size <<= 20;

	gc_off = true;

	early_init();

	if(p->image == NULL)
		p->image = default_image_path();

	srand(current_millis());
	init_primitives();
	init_ffi();
	init_stacks(p->ds_size,p->rs_size,p->cs_size);
	load_image(p);
	init_c_io();
	init_signals();

	stack_chain = NULL;

	userenv[CPU_ENV] = tag_object(from_char_string(FACTOR_CPU_STRING));
	userenv[OS_ENV] = tag_object(from_char_string(FACTOR_OS_STRING));
	userenv[CELL_SIZE_ENV] = tag_fixnum(sizeof(CELL));

	gc_off = false;
}

INLINE bool factor_arg(const char* str, const char* arg, CELL* value)
{
	int val;
	if(sscanf(str,arg,&val))
	{
		*value = val;
		return true;
	}
	else
		return false;
}

void init_factor_from_args(F_CHAR *image, int argc, char **argv, bool embedded)
{
	F_PARAMETERS p;
	default_parameters(&p);

	if(image) p.image = image;

	CELL i;

	for(i = 1; i < argc; i++)
	{
		if(factor_arg(argv[i],"-datastack=%d",&p.ds_size));
		else if(factor_arg(argv[i],"-retainstack=%d",&p.rs_size));
		else if(factor_arg(argv[i],"-callstack=%d",&p.cs_size));
		else if(factor_arg(argv[i],"-generations=%d",&p.gen_count));
		else if(factor_arg(argv[i],"-young=%d",&p.young_size));
		else if(factor_arg(argv[i],"-aging=%d",&p.aging_size));
		else if(factor_arg(argv[i],"-codeheap=%d",&p.code_size));
		else if(strcmp(argv[i],"-securegc") == 0)
			p.secure_gc = true;
		else if(strncmp(argv[i],"-i=",3) == 0)
			p.image = char_to_F_CHAR((char*)argv[i] + 3);
	}

	init_factor(&p);

	F_ARRAY *args = allot_array(ARRAY_TYPE,argc,F);

	for(i = 1; i < argc; i++)
	{
		REGISTER_ARRAY(args);
		CELL arg = tag_object(from_char_string(argv[i]));
		UNREGISTER_ARRAY(args);
		set_array_nth(args,i,arg);
	}

	userenv[ARGS_ENV] = tag_object(args);
	userenv[EXECUTABLE_ENV] = tag_object(from_char_string(argv[0]));
	userenv[EMBEDDED_ENV] = (embedded ? T : F);

	nest_stacks();
	call(userenv[BOOT_ENV]);
	run_toplevel();
	unnest_stacks();
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
