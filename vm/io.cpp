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

void factorvm::init_c_io()
{
	userenv[STDIN_ENV] = allot_alien(F,(cell)stdin);
	userenv[STDOUT_ENV] = allot_alien(F,(cell)stdout);
	userenv[STDERR_ENV] = allot_alien(F,(cell)stderr);
}


void factorvm::io_error()
{
#ifndef WINCE
	if(errno == EINTR)
		return;
#endif

	general_error(ERROR_IO,tag_fixnum(errno),F,NULL);
}


inline void factorvm::vmprim_fopen()
{
	gc_root<byte_array> mode(dpop(),this);
	gc_root<byte_array> path(dpop(),this);
	mode.untag_check(this);
	path.untag_check(this);

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

PRIMITIVE(fopen)
{
	PRIMITIVE_GETVM()->vmprim_fopen();
}

inline void factorvm::vmprim_fgetc()
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

PRIMITIVE(fgetc)
{
	PRIMITIVE_GETVM()->vmprim_fgetc();
}

inline void factorvm::vmprim_fread()
{
	FILE *file = (FILE *)unbox_alien();
	fixnum size = unbox_array_size();

	if(size == 0)
	{
		dpush(tag<string>(allot_string(0,0)));
		return;
	}

	gc_root<byte_array> buf(allot_array_internal<byte_array>(size),this);

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

PRIMITIVE(fread)
{
	PRIMITIVE_GETVM()->vmprim_fread();
}

inline void factorvm::vmprim_fputc()
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

PRIMITIVE(fputc)
{
	PRIMITIVE_GETVM()->vmprim_fputc();
}

inline void factorvm::vmprim_fwrite()
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

PRIMITIVE(fwrite)
{
	PRIMITIVE_GETVM()->vmprim_fwrite();
}

inline void factorvm::vmprim_fseek()
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

PRIMITIVE(fseek)
{
	PRIMITIVE_GETVM()->vmprim_fseek();
}

inline void factorvm::vmprim_fflush()
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

PRIMITIVE(fflush)
{
	PRIMITIVE_GETVM()->vmprim_fflush();
}

inline void factorvm::vmprim_fclose()
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

PRIMITIVE(fclose)
{
	PRIMITIVE_GETVM()->vmprim_fclose();
}

/* This function is used by FFI I/O. Accessing the errno global directly is
not portable, since on some libc's errno is not a global but a funky macro that
reads thread-local storage. */
int factorvm::err_no()
{
	return errno;
}

VM_C_API int err_no()
{
	return vm->err_no();
}

void factorvm::clear_err_no()
{
	errno = 0;
}

VM_C_API void clear_err_no()
{
	return vm->clear_err_no();
}

}
