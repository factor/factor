#include "master.h"

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
	simple_error(ERROR_IO,error,F);
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
	box_alien(file);
}

void primitive_fgetc(void)
{
	FILE* file = unbox_alien();
	int c = fgetc(file);
	if(c == EOF)
		dpush(F);
	else
		dpush(tag_fixnum(c));
}

void primitive_fread(void)
{
	FILE* file = unbox_alien();
	CELL size = unbox_array_size();

	if(size == 0)
	{
		dpush(tag_object(allot_string(0,0)));
		return;
	}

	F_BYTE_ARRAY *buf = allot_byte_array(size);
	int c = fread(buf + 1,1,size,file);
	if(c <= 0)
		dpush(F);
	else
		dpush(tag_object(memory_to_char_string((char *)(buf + 1),c)));
}

void primitive_fwrite(void)
{
	FILE* file = unbox_alien();
	F_STRING* text = untag_string(dpop());
	F_FIXNUM length = untag_fixnum_fast(text->length);

	if(string_capacity(text) == 0)
		return;

	if(!fwrite(to_char_string(text,false),1,length,file))
		io_error();
}

void primitive_fflush(void)
{
	fflush(unbox_alien());
}

void primitive_fclose(void)
{
	fclose(unbox_alien());
}

/* This function is used by FFI I/O. Accessing the errno global directly is
not portable, since on some libc's errno is not a global but a funky macro that
reads thread-local storage. */
int err_no(void)
{
	return errno;
}

/* Used by library/io/buffer/buffer.factor. Similar to C standard library
function strcspn(const char *s, const char *charset) */
long memcspn(const char *s, const char *end, const char *charset)
{
	const char *scan1, *scan2;

	for(scan1 = s; scan1 < end; scan1++)
	{
		for(scan2 = charset; *scan2; scan2++)
		{
			if(*scan1 == *scan2)
				return scan1 - s;
		}
	}

	return -1;
}
