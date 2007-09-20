int posix_argc;
F_CHAR **posix_argv;

DLLEXPORT void init_factor_from_args(F_CHAR *image, int argc, F_CHAR **argv, bool embedded);
DLLEXPORT char *factor_eval_string(char *string);
DLLEXPORT void factor_eval_free(char *result);
DLLEXPORT void factor_yield(void);
DLLEXPORT void factor_sleep(long ms);
