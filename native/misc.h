void primitive_exit(void);
void primitive_os_env(void);
void primitive_eq(void);
int64_t current_millis(void);
void primitive_millis(void);
void primitive_init_random(void);
void primitive_random_int(void);
#ifdef WIN32
F_STRING *last_error();
#endif

