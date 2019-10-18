#include "../factor.h"

void platform_run(void)
{
	run_toplevel();
}

void early_init(void) {}

const char *default_image_path(void)
{
	return "factor.image";
}
