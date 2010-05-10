namespace factor
{

VM_C_API char *alien_offset(cell object, factor_vm *vm);
VM_C_API char *pinned_alien_offset(cell object, factor_vm *vm);
VM_C_API cell allot_alien(void *address, factor_vm *vm);
VM_C_API cell from_value_struct(void *src, cell size, factor_vm *vm);
VM_C_API cell from_small_struct(cell x, cell y, cell size, factor_vm *vm);
VM_C_API cell from_medium_struct(cell x1, cell x2, cell x3, cell x4, cell size, factor_vm *vm);

}
