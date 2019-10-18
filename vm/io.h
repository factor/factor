void init_c_io(void);
void io_error(void);
void primitive_fopen(void);
void primitive_fwrite(void);
void primitive_fflush(void);
void primitive_fclose(void);
void primitive_fgetc(void);
void primitive_fread(void);

int err_no(void);
DLLEXPORT long memcspn(const char *s, const char *end, const char *charset);
