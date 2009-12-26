#include "master.hpp"

namespace factor
{

VM_C_API bool to_boolean(cell value, factor_vm *parent)
{
	return to_boolean(value);
}

VM_C_API cell from_boolean(bool value, factor_vm *parent)
{
	return parent->tag_boolean(value);
}

}
