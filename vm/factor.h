DLLEXPORT void default_parameters(F_PARAMETERS *p);
DLLEXPORT void init_parameters_from_args(F_PARAMETERS *p, int argc, F_CHAR **argv);
DLLEXPORT void init_factor(F_PARAMETERS *p);
DLLEXPORT void pass_args_to_factor(int argc, F_CHAR **argv);
DLLEXPORT void start_embedded_factor(F_PARAMETERS *p);
DLLEXPORT void start_standalone_factor(int argc, F_CHAR **argv);

DLLEXPORT char *factor_eval_string(char *string);
DLLEXPORT void factor_eval_free(char *result);
DLLEXPORT void factor_yield(void);
DLLEXPORT void factor_sleep(long ms);
