#include "master.hpp"

namespace factor
{

extern int main();

const char *vm_executable_path(void)
{
	static Dl_info info = {0};
	if (!info.dli_fname)
		dladdr(main, &info);
	return info.dli_fname;
}

}
