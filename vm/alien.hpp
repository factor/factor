namespace factor
{

VM_C_API char *alien_offset(cell object, factor_vm *vm);
VM_C_API char *unbox_alien(factor_vm *vm);
VM_C_API void box_alien(void *ptr, factor_vm *vm);
VM_C_API void to_value_struct(cell src, void *dest, cell size, factor_vm *vm);
VM_C_API void box_value_struct(void *src, cell size,factor_vm *vm);
VM_C_API void box_small_struct(cell x, cell y, cell size,factor_vm *vm);
VM_C_API void box_medium_struct(cell x1, cell x2, cell x3, cell x4, cell size,factor_vm *vm);

}
