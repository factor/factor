#include "factor.h"

/* Simple wrappers for ANSI C I/O functions, used for bootstrapping.
The Factor library provides platform-specific code for Unix and Windows
with many more capabilities.

Note that c-streams are pretty limited and broken. Namely,
there is a limit of 1024 characters per line, and lines containing
\0 are not read fully.

The native FFI streams in the library don't have this limitation. */

void init_c_io(void)
{
	userenv[IN_ENV] = tag_object(alien(stdin));
	userenv[OUT_ENV] = tag_object(alien(stdout));
}

void c_stream_error(void)
{
	CELL error = tag_object(from_c_string(strerror(errno)));
	general_error(ERROR_IO,error);
}

void primitive_fopen(void)
{
	char *path, *mode;
	FILE* file;
	maybe_garbage_collection();
	mode = unbox_c_string();
	path = unbox_c_string();
	file = fopen(path,mode);
	if(file == NULL)
		c_stream_error();
	box_alien(file);
}

#define FACTOR_LINE_LEN 1024

void primitive_fgets(void)
{
	FILE* file;
	char line[FACTOR_LINE_LEN];

	maybe_garbage_collection();

	file = (FILE*)unbox_alien();
	if(fgets(line,FACTOR_LINE_LEN,file) == NULL) 
	{
		if(feof(file))
			dpush(F);
		else
			c_stream_error();
	}
	else
		dpush(tag_object(from_c_string(line)));
}

void primitive_fwrite(void)
{
	FILE* file;
	F_STRING* text;
	maybe_garbage_collection();
	file = (FILE*)unbox_alien();
	text = untag_string(dpop());
	if(fwrite(to_c_string_unchecked(text),1,
		untag_fixnum_fast(text->length),
		file) == 0)
		c_stream_error();
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
