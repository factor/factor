#include "master.h"

void run(void)
{
	interpreter();
}

void run_toplevel(void)
{
	run();
}

void init_signals(void)
{
	unix_init_signals();
}

void early_init(void) { }

#define SUFFIX ".image"

const char *default_image_path(void)
{
	const char *path = vm_executable_path();

	if(!path)
		return "factor.image";

	char *new_path = safe_realloc(path,PATH_MAX + strlen(SUFFIX) + 1);
	strcat(new_path,SUFFIX); 
	return new_path;
}
