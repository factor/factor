namespace factor
{

inline static cell callstack_size(cell size)
{
	return sizeof(callstack) + size;
}

VM_ASM_API void save_callstack_bottom(stack_frame *callstack_bottom, factor_vm *vm);

}
