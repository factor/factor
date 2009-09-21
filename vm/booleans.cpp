#include "master.hpp"

namespace factor
{

void factorvm::box_boolean(bool value)
{
	dpush(value ? T : F);
}

VM_C_API void box_boolean(bool value, factorvm *myvm)
{
	ASSERTVM();
	return VM_PTR->box_boolean(value);
}

bool factorvm::to_boolean(cell value)
{
	return value != F;
}

VM_C_API bool to_boolean(cell value, factorvm *myvm)
{
	ASSERTVM();
	return VM_PTR->to_boolean(value);
}

}
