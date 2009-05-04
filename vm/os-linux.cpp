#include "master.hpp"

namespace factor
{

/* Snarfed from SBCL linux-so.c. You must free() this yourself. */
const char *vm_executable_path(void)
{
	char *path = (char *)safe_malloc(PATH_MAX + 1);

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

#ifdef SYS_inotify_init

int inotify_init(void)
{
	return syscall(SYS_inotify_init);
}

int inotify_add_watch(int fd, const char *name, u32 mask)
{
	return syscall(SYS_inotify_add_watch, fd, name, mask);
}

int inotify_rm_watch(int fd, u32 wd)
{
	return syscall(SYS_inotify_rm_watch, fd, wd);
}

#else

int inotify_init(void)
{
	not_implemented_error();
	return -1;
}

int inotify_add_watch(int fd, const char *name, u32 mask)
{
	not_implemented_error();
	return -1;
}

int inotify_rm_watch(int fd, u32 wd)
{
	not_implemented_error();
	return -1;
}

#endif

}
