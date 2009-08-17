#include "master.hpp"

namespace factor
{

void factorvm::box_boolean(bool value)
{
	dpush(value ? T : F);
}

VM_C_API void box_boolean(bool value)
{
	return vm->box_boolean(value);
}

bool factorvm::to_boolean(cell value)
{
	return value != F;
}

VM_C_API bool to_boolean(cell value)
{
	return vm->to_boolean(value);
}

}
