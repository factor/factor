#include "factor.h"

int main(int argc, char** argv)
{
	if(argc == 1)
	{
		printf("Usage: factor <image file> [ parameters ... ]\n");
		printf("\n");
		
		return 1;
	}

	init_arena(DEFAULT_ARENA);
	load_image(argv[1]);
	init_stacks();
	init_iomux();
	init_io();

	run();

	return 0;
}
