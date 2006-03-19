#include "../factor.h"

void platform_run(void)
{
	run_toplevel();
}

void early_init(void) {}

char *default_image_path()
{
	return "factor.image";
}
