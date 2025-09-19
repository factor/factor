namespace factor {

void init_mvm();
void register_vm_with_thread(factor_vm* vm);
factor_vm* current_vm_p();

inline factor_vm* current_vm() {
  factor_vm* vm = current_vm_p();
  FACTOR_ASSERT(vm != nullptr);
  return vm;
}

VM_C_API THREADHANDLE start_standalone_factor_in_new_thread(int argc,
                                                            vm_char** argv);

extern std::map<THREADHANDLE, factor_vm*> thread_vms;

}
