namespace factor
{

VM_C_API bool to_boolean(cell value, factor_vm *vm);
VM_C_API cell from_boolean(bool value, factor_vm *vm);

/* Cannot allocate */
inline static bool to_boolean(cell value)
{
	return value != false_object;
}

}
