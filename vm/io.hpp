namespace factor
{

void init_c_io();
void io_error();

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

VM_C_API int err_no();
VM_C_API void clear_err_no();

}
