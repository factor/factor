#include "master.h"

/* Snarfed from SBCL linux-so.c. You must free() this yourself. */
const char *vm_executable_path(void)
{
	char *path = safe_malloc(PATH_MAX + 1);

	int size = readlink("/proc/self/exe", path, PATH_MAX);
	if (size < 0)
	{
		fatal_error("Cannot read /proc/self/exe",0);
		return NULL;
	}
	else
	{
		path[size] = '\0';
		return safe_strdup(path);
	}
}
