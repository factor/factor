void primitive_exit(void);
void primitive_os_env(void);
void primitive_eq(void);
s64 current_millis(void);
void primitive_millis(void);
void primitive_random_int(void);
#ifdef WIN32
char *buffer_to_c_string(char *buffer);
DLLEXPORT char *last_error();
#endif

