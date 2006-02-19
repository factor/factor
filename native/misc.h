void *safe_malloc(size_t size);
void primitive_exit(void);
void primitive_os_env(void);
void primitive_eq(void);
s64 current_millis(void);
void primitive_millis(void);
#ifdef WIN32
char *buffer_to_c_string(char *buffer);
F_STRING *get_error_message(void);
DLLEXPORT char *error_message(DWORD id);
#endif
