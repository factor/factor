namespace factor
{

VM_C_API void box_boolean(bool value, factor_vm *vm);
VM_C_API bool to_boolean(cell value, factor_vm *vm);

inline cell factor_vm::tag_boolean(cell untagged)
{
	return (untagged ? true_object : false_object);
}

inline bool factor_vm::to_boolean(cell value)
{
	return value != false_object;
}

}
