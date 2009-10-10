#include "master.hpp"

namespace factor
{

void factor_vm::box_boolean(bool value)
{
	dpush(value ? T : F);
}

VM_C_API void box_boolean(bool value, factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_boolean(value);
}

bool factor_vm::to_boolean(cell value)
{
	return value != F;
}

VM_C_API bool to_boolean(cell value, factor_vm *myvm)
{
	ASSERTVM();
	return VM_PTR->to_boolean(value);
}

}
