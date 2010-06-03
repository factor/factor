namespace factor
{

VM_C_API void init_globals();
factor_vm *new_factor_vm();
VM_C_API void start_standalone_factor(int argc, vm_char **argv);

}
