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
	if(scanf(CELL_HEX_FORMAT,&cell) < 0) exit(1);
	return cell;
}

}
