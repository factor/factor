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
with many more capabilities.

Note that c-streams are pretty limited and broken. Namely,
there is a limit of 1024 characters per line, and lines containing
\0 are not read fully.

The native FFI streams in the library don't have this limitation. */

void init_c_io(void)
{
	userenv[IN_ENV] = tag_object(make_alien(F,(CELL)stdin));
	userenv[OUT_ENV] = tag_object(make_alien(F,(CELL)stdout));
}

void io_error(void)
{
	CELL error = tag_object(from_c_string(strerror(errno)));
	general_error(ERROR_IO,error,F,true);
}

void primitive_fopen(void)
{
	char *path, *mode;
	FILE* file;
	maybe_gc(0);
	mode = pop_c_string();
	path = pop_c_string();
	file = fopen(path,mode);
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
	FILE* file;
	F_STRING* text;
	maybe_gc(0);
	file = (FILE*)unbox_alien();
	text = untag_string(dpop());

	if(string_capacity(text) == 0)
		return;

	if(fwrite(to_c_string(text,false),1,
		untag_fixnum_fast(text->length),
		file) == 0)
		io_error();
}

void primitive_fflush(void)
{
	FILE* file = (FILE*)unbox_alien();
	fflush(file);
}

void primitive_fclose(void)
{
	FILE* file = (FILE*)unbox_alien();
	fclose(file);
}
