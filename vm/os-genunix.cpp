#include "master.hpp"

namespace factor
{

void c_to_factor_toplevel(cell quot)
{
	c_to_factor(quot);
}

void init_signals(void)
{
	unix_init_signals();
}

void early_init(void) { }

#define SUFFIX ".image"
#define SUFFIX_LEN 6

const char *default_image_path(void)
{
	const char *path = vm_executable_path();

	if(!path)
		return "factor.image";

	/* We can't call strlen() here because with gcc 4.1.2 this
	causes an internal compiler error. */
	int len = 0;
	const char *iter = path;
	while(*iter) { len++; iter++; }

	char *new_path = (char *)safe_malloc(PATH_MAX + SUFFIX_LEN + 1);
	memcpy(new_path,path,len + 1);
	memcpy(new_path + len,SUFFIX,SUFFIX_LEN + 1);
	return new_path;
}

}
