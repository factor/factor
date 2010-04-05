namespace factor
{

void init_mvm();
void register_vm_with_thread(factor_vm *vm);
factor_vm *current_vm();

VM_C_API THREADHANDLE start_standalone_factor_in_new_thread(int argc, vm_char **argv);

extern std::map<THREADHANDLE, factor_vm *> thread_vms;

}
