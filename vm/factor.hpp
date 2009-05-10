namespace factor
{

VM_C_API void default_parameters(vm_parameters *p);
VM_C_API void init_parameters_from_args(vm_parameters *p, int argc, vm_char **argv);
VM_C_API void init_factor(vm_parameters *p);
VM_C_API void pass_args_to_factor(int argc, vm_char **argv);
VM_C_API void start_embedded_factor(vm_parameters *p);
VM_C_API void start_standalone_factor(int argc, vm_char **argv);

VM_C_API char *factor_eval_string(char *string);
VM_C_API void factor_eval_free(char *result);
VM_C_API void factor_yield();
VM_C_API void factor_sleep(long ms);

}
