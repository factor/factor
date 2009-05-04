namespace factor
{

void init_c_io(void);
void io_error(void);

PRIMITIVE(fopen);
PRIMITIVE(fgetc);
PRIMITIVE(fread);
PRIMITIVE(fputc);
PRIMITIVE(fwrite);
PRIMITIVE(fflush);
PRIMITIVE(fseek);
PRIMITIVE(fclose);

/* Platform specific primitives */
PRIMITIVE(open_file);
PRIMITIVE(existsp);
PRIMITIVE(read_dir);

VM_C_API int err_no(void);
VM_C_API void clear_err_no(void);

}
