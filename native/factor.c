#include "factor.h"

void init_factor(char* image)
{
	init_arena(DEFAULT_ARENA);
	load_image(image);
	init_stacks();
	init_io();

#ifdef WIN32
	init_signals();
#endif

	init_compiler();
	init_errors();
	gc_time = 0;

#ifdef FACTOR_X86
	userenv[CPU_ENV] = tag_object(from_c_string("x86"));
#else
	userenv[CPU_ENV] = tag_object(from_c_string("unknown"));
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

	run();

	return 0;
}
