#include "factor.h"

/* This function is used by FFI I/O. Accessing the errno global is
too troublesome... on some libc's its a funky macro that reads
thread-local storage. */
int err_no(void)
{
	return errno;
}

/* Simple wrappers for ANSI C I/O functions, used for bootstrapping.
The Factor library provides platform-specific code for Unix and Windows
with many more capabilities. */

void init_c_io(void)
{
	userenv[IN_ENV] = allot_alien(F,(CELL)stdin);
	userenv[OUT_ENV] = allot_alien(F,(CELL)stdout);
}

void io_error(void)
{
	CELL error = tag_object(from_char_string(strerror(errno)));
	general_error(ERROR_IO,error,F,true);
}

void primitive_fopen(void)
{
	char *mode = unbox_char_string();
	REGISTER_C_STRING(mode);
	char *path = unbox_char_string();
	UNREGISTER_C_STRING(mode);
	FILE *file = fopen(path,mode);
	if(file == NULL)
		io_error();
	box_alien((CELL)file);
}

void primitive_fgetc(void)
{
	FILE* file = (FILE*)unbox_alien();
	int c = fgetc(file);
	if(c == EOF)
		dpush(F);
	else
		dpush(tag_fixnum(c));
}

void primitive_fwrite(void)
{
	FILE* file = (FILE*)unbox_alien();
	F_STRING* text = untag_string(dpop());
	F_FIXNUM length = untag_fixnum_fast(text->length);

	if(string_capacity(text) == 0)
		return;

	if(!fwrite(to_char_string(text,false),1,length,file))
		io_error();
}

void primitive_fflush(void)
{
	fflush((FILE*)unbox_alien());
}

void primitive_fclose(void)
{
	fclose((FILE*)unbox_alien());
}
