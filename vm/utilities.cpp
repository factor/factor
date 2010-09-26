#include "master.hpp"

namespace factor
{

/* If memory allocation fails, bail out */
vm_char *safe_strdup(const vm_char *str)
{
	vm_char *ptr = STRDUP(str);
	if(!ptr) fatal_error("Out of memory in safe_strdup", 0);
	return ptr;
}

cell read_cell_hex()
{
	cell cell;
	std::cin >> std::hex >> cell >> std::dec;
	if(!std::cin.good()) exit(1);
	return cell;
}

/* On Windows, memcpy() is in a different DLL and the non-optimizing
compiler can't find it */
VM_C_API void *factor_memcpy(void *dst, void *src, size_t len)
{
	return memcpy(dst,src,len);
}

}
