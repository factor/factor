#include "master.hpp"

namespace factor
{

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
	userenv[STDIN_ENV] = allot_alien(F,(cell)stdin);
	userenv[STDOUT_ENV] = allot_alien(F,(cell)stdout);
	userenv[STDERR_ENV] = allot_alien(F,(cell)stderr);
}

void io_error(void)
{
#ifndef WINCE
	if(errno == EINTR)
		return;
#endif

	general_error(ERROR_IO,tag_fixnum(errno),F,NULL);
}

PRIMITIVE(fopen)
{
	gc_root<byte_array> mode(dpop());
	gc_root<byte_array> path(dpop());
	mode.untag_check();
	path.untag_check();

	for(;;)
	{
		FILE *file = fopen((char *)(path.untagged() + 1),
				   (char *)(mode.untagged() + 1));
		if(file == NULL)
			io_error();
		else
		{
			box_alien(file);
			break;
		}
	}
}

PRIMITIVE(fgetc)
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

PRIMITIVE(fread)
{
	FILE *file = (FILE *)unbox_alien();
	fixnum size = unbox_array_size();

	if(size == 0)
	{
		dpush(tag<string>(allot_string(0,0)));
		return;
	}

	gc_root<byte_array> buf(allot_array_internal<byte_array>(size));

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
				byte_array *new_buf = allot_byte_array(c);
				memcpy(new_buf + 1, buf.untagged() + 1,c);
				buf = new_buf;
			}
			dpush(buf.value());
			break;
		}
	}
}

PRIMITIVE(fputc)
{
	FILE *file = (FILE *)unbox_alien();
	fixnum ch = to_fixnum(dpop());

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

PRIMITIVE(fwrite)
{
	FILE *file = (FILE *)unbox_alien();
	byte_array *text = untag_check<byte_array>(dpop());
	cell length = array_capacity(text);
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

PRIMITIVE(fseek)
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

PRIMITIVE(fflush)
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

PRIMITIVE(fclose)
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
VM_C_API int err_no(void)
{
	return errno;
}

VM_C_API void clear_err_no(void)
{
	errno = 0;
}

}
