void init_c_io(void);
void io_error(void);
DLLEXPORT int err_no(void);
DLLEXPORT void clear_err_no(void);

void primitive_fopen(void);
void primitive_fgetc(void);
void primitive_fread(void);
void primitive_fputc(void);
void primitive_fwrite(void);
void primitive_fflush(void);
void primitive_fseek(void);
void primitive_fclose(void);

/* Platform specific primitives */
void primitive_open_file(void);
void primitive_existsp(void);
void primitive_read_dir(void);
