namespace factor
{

VM_C_API void box_boolean(bool value, factor_vm *vm);
VM_C_API bool to_boolean(cell value, factor_vm *vm);

inline static bool to_boolean(cell value)
{
	return value != false_object;
}

}
