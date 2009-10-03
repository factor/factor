#include "master.hpp"

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
	return new_path;
}

}
