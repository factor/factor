#include "factor.h"

void init_factor(char* image, CELL ds_size, CELL cs_size,
	CELL data_size, CELL code_size)
{
	init_arena(data_size);
	init_compiler(code_size);
	load_image(image);
	init_stacks(ds_size,cs_size);
	init_c_io();
	init_signals();

	init_errors();

#if defined(FACTOR_X86)
	userenv[CPU_ENV] = tag_object(from_c_string("x86"));
#elif defined(FACTOR_PPC)
	userenv[CPU_ENV] = tag_object(from_c_string("ppc"));
#else
	userenv[CPU_ENV] = tag_object(from_c_string("unknown"));
#endif

#ifdef WIN32
	userenv[OS_ENV] = tag_object(from_c_string("win32"));
#else
	userenv[OS_ENV] = tag_object(from_c_string("unix"));
#endif
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
	CELL ds_size = 2048;
	CELL cs_size = 2048;
	CELL data_size = 16;
	CELL code_size = 2;
	CELL args;
	CELL i;

	if(argc == 1)
	{
		printf("Usage: factor <image file> [ parameters ... ]\n");
		printf("Runtime options -- n is a number:\n");
		printf(" +Dn   Data stack size, kilobytes\n");
		printf(" +Cn   Call stack size, kilobytes\n");
		printf(" +Mn   Data heap size, megabytes\n");
		printf(" +Xn   Code heap size, megabytes\n");
		printf("Other options are handled by the Factor library.\n");
		printf("See the documentation for details.\n");
		printf("Send bug reports to Slava Pestov <slava@jedit.org>.\n");
		return 1;
	}

	for(i = 1; i < argc; i++)
	{
		if(factor_arg(argv[i],"+D%d",&ds_size)) continue;
		if(factor_arg(argv[i],"+C%d",&cs_size)) continue;
		if(factor_arg(argv[i],"+M%d",&data_size)) continue;
		if(factor_arg(argv[i],"+X%d",&code_size)) continue;

		if(strncmp(argv[i],"+",1) == 0)
		{
			printf("Unknown option: %s\n",argv[i]);
			return 1;
		}
	}

	init_factor(argv[1],
		ds_size * 1024,
		cs_size * 1024,
		data_size * 1024 * 1024,
		code_size * 1024 * 1024);

	args = F;
	while(--argc != 0)
	{
		args = cons(tag_object(from_c_string(argv[argc])),args);
	}

	userenv[ARGS_ENV] = args;

	platform_run();

	return 0;
}
