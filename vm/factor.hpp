VM_C_API void default_parameters(F_PARAMETERS *p);
VM_C_API void init_parameters_from_args(F_PARAMETERS *p, int argc, F_CHAR **argv);
VM_C_API void init_factor(F_PARAMETERS *p);
VM_C_API void pass_args_to_factor(int argc, F_CHAR **argv);
VM_C_API void start_embedded_factor(F_PARAMETERS *p);
VM_C_API void start_standalone_factor(int argc, F_CHAR **argv);

VM_C_API char *factor_eval_string(char *string);
VM_C_API void factor_eval_free(char *result);
VM_C_API void factor_yield(void);
VM_C_API void factor_sleep(long ms);
