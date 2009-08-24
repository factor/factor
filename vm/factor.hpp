namespace factor
{

VM_C_API void start_standalone_factor(int argc, vm_char **argv);
VM_C_API void *start_standalone_factor_in_new_thread(int argc, vm_char **argv);
}
