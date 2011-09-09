#include "master.hpp"

namespace factor
{

/* Snarfed from SBCL linux-so.c. You must free() the result yourself. */
const char *vm_executable_path()
{
	char *path = new char[PATH_MAX + 1];

	int size = readlink("/proc/self/exe", path, PATH_MAX);
	if (size < 0)
	{
		fatal_error("Cannot read /proc/self/exe",0);
		return NULL;
	}
	else
	{
		path[size] = '\0';

		const char *ret = safe_strdup(path);
		delete[] path;
		return ret;
	}
}

}
