#include "factor.h"

void platform_run(void)
{
	run_toplevel();
}

const char *default_image_path(void)
{
	return "factor.image";
}

void init_signals(void)
{
	unix_init_signals();
}
