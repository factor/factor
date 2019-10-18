#include "factor.h"

int main(int argc, char** argv)
{
	CELL args;

	if(argc == 1)
	{
		printf("Usage: factor <image file> [ parameters ... ]\n");
		printf("\n");
		
		return 1;
	}

	init_arena(DEFAULT_ARENA);
	load_image(argv[1]);
	init_stacks();
	init_io();
	init_signals();
	init_compiler();
	init_errors();

	args = F;
	while(--argc != 0)
	{
		args = cons(tag_object(from_c_string(argv[argc])),args);
	}

	userenv[ARGS_ENV] = args;

#ifdef FACTOR_X86
	userenv[CPU_ENV] = tag_object(from_c_string("x86"));
#else
	userenv[CPU_ENV] = tag_object(from_c_string("unknown"));
#endif

	run();

	return 0;
}
