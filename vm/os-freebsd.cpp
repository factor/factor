#include "master.hpp"

namespace factor
{

/* From SBCL */
const char *vm_executable_path()
{
	char path[PATH_MAX + 1];

	if (getosreldate() >= 600024)
	{
		/* KERN_PROC_PATHNAME is available */
		size_t len = PATH_MAX + 1;
		int mib[4];

		mib[0] = CTL_KERN;
		mib[1] = KERN_PROC;
		mib[2] = KERN_PROC_PATHNAME;
		mib[3] = -1;
		if (sysctl(mib, 4, &path, &len, NULL, 0) != 0)
			return NULL;
	}
	else
	{
		int size;
		size = readlink("/proc/curproc/file", path, sizeof(path) - 1);
		if (size < 0)
			return NULL;
		path[size] = '\0';
	}

	if(strcmp(path, "unknown") == 0)
		return NULL;

	return safe_strdup(path);
}

}
