#include "factor.h"

void run(void)
{
	interpreter();
}

void run_toplevel(void)
{
	run();
}

const char *default_image_path(void)
{
	return "factor.image";
}

void init_signals(void)
{
	unix_init_signals();
}
