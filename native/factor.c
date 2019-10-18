#include "factor.h"

void init_factor(const char* image, CELL ds_size, CELL cs_size,
	CELL gen_count,
	CELL young_size, CELL aging_size,
	CELL code_size, CELL literal_size)
{
	init_ffi();
	init_arena(gen_count,young_size,aging_size);
	init_compiler(code_size);
	init_stacks(ds_size,cs_size);
	/* callframe must be valid in case load_image() does GC */
	callframe = F;
	thrown_error = F;
	load_image(image,literal_size);
	callframe = userenv[BOOT_ENV];
	init_c_io();
	init_signals();
	userenv[CPU_ENV] = tag_object(from_c_string(FACTOR_CPU_STRING));
	userenv[OS_ENV] = tag_object(from_c_string(FACTOR_OS_STRING));
	userenv[GEN_ENV] = tag_fixnum(gen_count);
	userenv[CARD_OFF_ENV] = tag_cell(cards_offset);
	userenv[IMAGE_ENV] = tag_object(from_c_string(image));
	userenv[CELL_SIZE_ENV] = tag_fixnum(sizeof(CELL));
	userenv[COMPILED_BASE_ENV] = tag_cell(compiling.base);
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

void usage(void)
{
	printf("Usage: factor <image file> [ parameters ... ]\n");
	printf("Runtime options -- n is a number:\n");
	printf(" +Dn   Data stack size, kilobytes\n");
	printf(" +Cn   Call stack size, kilobytes\n");
	printf(" +Gn   Number of generations, must be >= 2\n");
	printf(" +Yn   Size of n-1 youngest generations, megabytes\n");
	printf(" +An   Size of tenured and semi-spaces, megabytes\n");
	printf(" +Xn   Code heap size, megabytes\n");
	printf("Other options are handled by the Factor library.\n");
	printf("See the documentation for details.\n");
	printf("Send bug reports to Slava Pestov <slava@factorcode.org>.\n");
}

int main(int argc, char** argv)
{
	const char *image = NULL;
	CELL ds_size = 128;
	CELL cs_size = 128;
	CELL generations = 2;
	CELL young_size = 2 * CELLS;
	CELL aging_size = 4 * CELLS;
	CELL code_size = CELLS;
	CELL literal_size = 128;
	CELL args;
	CELL i;

	early_init();

	for(i = 1; i < argc; i++)
	{
		if(factor_arg(argv[i],"+D%d",&ds_size)) continue;
		if(factor_arg(argv[i],"+C%d",&cs_size)) continue;
		if(factor_arg(argv[i],"+G%d",&generations)) continue;
		if(factor_arg(argv[i],"+Y%d",&young_size)) continue;
		if(factor_arg(argv[i],"+A%d",&aging_size)) continue;
		if(factor_arg(argv[i],"+X%d",&code_size)) continue;

		if(strncmp(argv[i],"+",1) == 0)
		{
			printf("Unknown option: %s\n",argv[i]);
			usage();
			return 1;
		}

		if(strncmp(argv[i],"-",1) != 0 && image == NULL)
			image = argv[1];
	}

	if(image == NULL)
		image = default_image_path();

	init_factor(image,
		ds_size * 1024,
		cs_size * 1024,
		generations,
		young_size * 1024 * 1024,
		aging_size * 1024 * 1024,
		code_size * 1024 * 1024,
		literal_size * 1024);

	args = F;
	while(--argc > 1)
	{
		args = cons(tag_object(from_c_string(argv[argc])),args);
	}

	userenv[ARGS_ENV] = args;

	platform_run();

	critical_error("run() returned due to empty callstack",0);

	return 0;
}
