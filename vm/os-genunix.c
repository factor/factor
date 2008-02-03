#include "master.h"

void c_to_factor_toplevel(CELL quot)
{
	c_to_factor(quot);
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

	char *new_path = safe_malloc(PATH_MAX + strlen(SUFFIX) + 1);
	memcpy(new_path,path,strlen(path) + 1);
	strcat(new_path,SUFFIX); 
	return new_path;
}
