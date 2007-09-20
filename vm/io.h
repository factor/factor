void init_c_io(void);
void io_error(void);
int err_no(void);

DECLARE_PRIMITIVE(fopen);
DECLARE_PRIMITIVE(fwrite);
DECLARE_PRIMITIVE(fflush);
DECLARE_PRIMITIVE(fclose);
DECLARE_PRIMITIVE(fgetc);
DECLARE_PRIMITIVE(fread);

/* Platform specific primitives */
DECLARE_PRIMITIVE(open_file);
DECLARE_PRIMITIVE(stat);
DECLARE_PRIMITIVE(read_dir);
DECLARE_PRIMITIVE(cwd);
DECLARE_PRIMITIVE(cd);
