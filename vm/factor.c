#include "factor.h"

/* Get things started */
void init_factor(const char* image,
	CELL ds_size, CELL rs_size, CELL cs_size,
	CELL gen_count, CELL young_size, CELL aging_size,
	CELL code_size,
	bool secure_gc)
{
	srand(current_millis());
	init_ffi();
	init_data_heap(gen_count,young_size,aging_size,secure_gc);
	init_code_heap(code_size);
	init_stacks(ds_size,rs_size,cs_size);
	/* callframe must be valid in case load_image() does GC */
	callframe = F;
	callframe_scan = callframe_end = 0;
	thrown_error = F;
	load_image(image);
	call(userenv[BOOT_ENV]);
	init_c_io();
	init_signals();
	userenv[CPU_ENV] = tag_object(from_char_string(FACTOR_CPU_STRING));
	userenv[OS_ENV] = tag_object(from_char_string(FACTOR_OS_STRING));
	userenv[GEN_ENV] = tag_fixnum(gen_count);
	userenv[IMAGE_ENV] = tag_object(from_char_string(image));
	userenv[CELL_SIZE_ENV] = tag_fixnum(sizeof(CELL));
	userenv[CODE_HEAP_START_ENV] = allot_cell(compiling.base);
	userenv[CODE_HEAP_END_ENV] = allot_cell(compiling.limit);
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

int main(int argc, char** argv)
{
	const char *image = NULL;
	CELL ds_size = 128;
	CELL rs_size = 128;
	CELL cs_size = 128;
	CELL generations = 2;
	CELL young_size = 4 * CELLS;
	CELL aging_size = 8 * CELLS;
	CELL code_size = CELLS;
	F_ARRAY *args;
	CELL arg_count;
	CELL i;
	bool image_given = true;
	bool secure_gc = false;

	early_init();

	for(i = 1; i < argc; i++)
	{
		if(factor_arg(argv[i],"-D=%d",&ds_size)) continue;
		if(factor_arg(argv[i],"-R=%d",&rs_size)) continue;
		if(factor_arg(argv[i],"-C=%d",&cs_size)) continue;
		if(factor_arg(argv[i],"-G=%d",&generations)) continue;
		if(factor_arg(argv[i],"-Y=%d",&young_size)) continue;
		if(factor_arg(argv[i],"-A=%d",&aging_size)) continue;
		if(factor_arg(argv[i],"-X=%d",&code_size)) continue;
		if(strcmp(argv[i],"-S") == 0) { secure_gc = true; continue; }

		if(strncmp(argv[i],"-",1) != 0 && image == NULL)
			image = argv[1];
	}

	if(image == NULL)
	{
		image_given = false;
		image = default_image_path();
	}

	init_factor(image,
		ds_size * 1024,
		rs_size * 1024,
		cs_size * 1024,
		generations,
		young_size * 1024 * 1024,
		aging_size * 1024 * 1024,
		code_size * 1024 * 1024,
		secure_gc);

	arg_count = (image_given ? 2 : 1);

	args = allot_array(ARRAY_TYPE,argc,F);

	for(i = arg_count; i < argc; i++)
	{
		REGISTER_ARRAY(args);
		CELL arg = tag_object(from_char_string(argv[i]));
		UNREGISTER_ARRAY(args);
		set_array_nth(args,i,arg);
	}

	userenv[ARGS_ENV] = tag_object(args);

	run_toplevel();

	return 0;
}
