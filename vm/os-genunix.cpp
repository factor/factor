#include "master.hpp"
#include <time.h>

namespace factor
{

void factor_vm::c_to_factor_toplevel(cell quot)
{
	c_to_factor(quot,this);
}

void init_signals()
{
	unix_init_signals();
}

void early_init() { }

#define SUFFIX ".image"
#define SUFFIX_LEN 6

/* You must delete[] the result yourself. */
const char *default_image_path()
{
	const char *path = vm_executable_path();

	if(!path)
		return "factor.image";

	int len = strlen(path);
	char *new_path = new char[PATH_MAX + SUFFIX_LEN + 1];
	memcpy(new_path,path,len + 1);
	memcpy(new_path + len,SUFFIX,SUFFIX_LEN + 1);
	free(const_cast<char *>(path));
	return new_path;
}

u64 nano_count()
{
	struct timespec t;
	int ret;
	ret = clock_gettime(CLOCK_MONOTONIC,&t);
	if(ret != 0)
		fatal_error("clock_gettime failed", 0);
	return (u64)t.tv_sec * 1000000000 + t.tv_nsec;
}

}
