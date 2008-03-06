void init_c_io(void);
void io_error(void);
int err_no(void);

DECLARE_PRIMITIVE(fopen);
DECLARE_PRIMITIVE(fgetc);
DECLARE_PRIMITIVE(fread);
DECLARE_PRIMITIVE(fputc);
DECLARE_PRIMITIVE(fwrite);
DECLARE_PRIMITIVE(fflush);
DECLARE_PRIMITIVE(fclose);

/* Platform specific primitives */
DECLARE_PRIMITIVE(open_file);
DECLARE_PRIMITIVE(stat);
DECLARE_PRIMITIVE(read_dir);
