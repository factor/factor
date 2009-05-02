#include "master.hpp"

/* Simple wrappers for ANSI C I/O functions, used for bootstrapping.

Note the ugly loop logic in almost every function; we have to handle EINTR
and restart the operation if the system call was interrupted. Naive
applications don't do this, but then they quickly fail if one enables
itimer()s or other signals.

The Factor library provides platform-specific code for Unix and Windows
with many more capabilities so these words are not usually used in
normal operation. */

void init_c_io(void)
{
	userenv[STDIN_ENV] = allot_alien(F,(CELL)stdin);
	userenv[STDOUT_ENV] = allot_alien(F,(CELL)stdout);
	userenv[STDERR_ENV] = allot_alien(F,(CELL)stderr);
}

void io_error(void)
{
#ifndef WINCE
	if(errno == EINTR)
		return;
#endif

	CELL error = tag_object(from_char_string(strerror(errno)));
	general_error(ERROR_IO,error,F,NULL);
}

void primitive_fopen(void)
{
	char *mode = unbox_char_string();
	REGISTER_C_STRING(mode);
	char *path = unbox_char_string();
	UNREGISTER_C_STRING(char,mode);

	for(;;)
	{
		FILE *file = fopen(path,mode);
		if(file == NULL)
			io_error();
		else
		{
			box_alien(file);
			break;
		}
	}
}

void primitive_fgetc(void)
{
	FILE *file = (FILE *)unbox_alien();

	for(;;)
	{
		int c = fgetc(file);
		if(c == EOF)
		{
			if(feof(file))
			{
				dpush(F);
				break;
			}
			else
				io_error();
		}
		else
		{
			dpush(tag_fixnum(c));
			break;
		}
	}
}

void primitive_fread(void)
{
	FILE *file = (FILE *)unbox_alien();
	F_FIXNUM size = unbox_array_size();

	if(size == 0)
	{
		dpush(tag_object(allot_string(0,0)));
		return;
	}

	gc_root<F_BYTE_ARRAY> buf(allot_array_internal<F_BYTE_ARRAY>(size));

	for(;;)
	{
		int c = fread(buf.untagged() + 1,1,size,file);
		if(c <= 0)
		{
			if(feof(file))
			{
				dpush(F);
				break;
			}
			else
				io_error();
		}
		else
		{
			if(c != size)
			{
				F_BYTE_ARRAY *new_buf = allot_byte_array(c);
				memcpy(new_buf + 1, buf.untagged() + 1,c);
				buf = new_buf;
			}
			dpush(buf.value());
			break;
		}
	}
}

void primitive_fputc(void)
{
	FILE *file = (FILE *)unbox_alien();
	F_FIXNUM ch = to_fixnum(dpop());

	for(;;)
	{
		if(fputc(ch,file) == EOF)
		{
			io_error();

			/* Still here? EINTR */
		}
		else
			break;
	}
}

void primitive_fwrite(void)
{
	FILE *file = (FILE *)unbox_alien();
	F_BYTE_ARRAY *text = untag_byte_array(dpop());
	CELL length = array_capacity(text);
	char *string = (char *)(text + 1);

	if(length == 0)
		return;

	for(;;)
	{
		size_t written = fwrite(string,1,length,file);
		if(written == length)
			break;
		else
		{
			if(feof(file))
				break;
			else
				io_error();

			/* Still here? EINTR */
			length -= written;
			string += written;
		}
	}
}

void primitive_fseek(void)
{
	int whence = to_fixnum(dpop());
	FILE *file = (FILE *)unbox_alien();
	off_t offset = to_signed_8(dpop());

	switch(whence)
	{
	case 0: whence = SEEK_SET; break;
	case 1: whence = SEEK_CUR; break;
	case 2: whence = SEEK_END; break;
	default:
		critical_error("Bad value for whence",whence);
		break;
	}

	if(FSEEK(file,offset,whence) == -1)
	{
		io_error();

		/* Still here? EINTR */
		critical_error("Don't know what to do; EINTR from fseek()?",0);
	}
}

void primitive_fflush(void)
{
	FILE *file = (FILE *)unbox_alien();
	for(;;)
	{
		if(fflush(file) == EOF)
			io_error();
		else
			break;
	}
}

void primitive_fclose(void)
{
	FILE *file = (FILE *)unbox_alien();
	for(;;)
	{
		if(fclose(file) == EOF)
			io_error();
		else
			break;
	}
}

/* This function is used by FFI I/O. Accessing the errno global directly is
not portable, since on some libc's errno is not a global but a funky macro that
reads thread-local storage. */
int err_no(void)
{
	return errno;
}

void clear_err_no(void)
{
	errno = 0;
}
