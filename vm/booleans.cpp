#include "master.hpp"

namespace factor
{

void factor_vm::box_boolean(bool value)
{
	dpush(tag_boolean(value));
}

VM_C_API void box_boolean(bool value, factor_vm *parent)
{
	return parent->box_boolean(value);
}

VM_C_API bool to_boolean(cell value, factor_vm *parent)
{
	return parent->to_boolean(value);
}

}
