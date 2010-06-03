namespace factor
{

VM_C_API char *alien_offset(cell object, factor_vm *vm);
VM_C_API char *pinned_alien_offset(cell object, factor_vm *vm);
VM_C_API cell allot_alien(void *address, factor_vm *vm);

}
