#include "factor.h"

void init_factor(char* image)
{
	init_arena(DEFAULT_ARENA);
	load_image(image);
	init_stacks();
	init_io();
	init_signals();

	init_errors();

#ifdef FACTOR_X86
	userenv[CPU_ENV] = tag_object(from_c_string("x86"));
#else
	userenv[CPU_ENV] = tag_object(from_c_string("unknown"));
#endif

#ifdef WIN32
	userenv[OS_ENV] = tag_object(from_c_string("win32"));
#else
	userenv[OS_ENV] = tag_object(from_c_string("unix"));
#endif
}

int main(int argc, char** argv)
{
	CELL args;

	if(argc == 1)
	{
		printf("Usage: factor <image file> [ parameters ... ]\n");
		printf("\n");
		
		return 1;
	}

	init_factor(argv[1]);

	args = F;
	while(--argc != 0)
	{
		args = cons(tag_object(from_c_string(argv[argc])),args);
	}

	userenv[ARGS_ENV] = args;

	platform_run();

	return 0;
}
