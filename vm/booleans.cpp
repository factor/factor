#include "master.hpp"

VM_C_API void box_boolean(bool value)
{
	dpush(value ? T : F);
}

VM_C_API bool to_boolean(CELL value)
{
	return value != F;
}
