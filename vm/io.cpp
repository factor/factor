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

void factor_vm::init_c_io()
{
	special_objects[OBJ_STDIN] = allot_alien(false_object,(cell)stdin);
	special_objects[OBJ_STDOUT] = allot_alien(false_object,(cell)stdout);
	special_objects[OBJ_STDERR] = allot_alien(false_object,(cell)stderr);
}

void factor_vm::io_error()
{
#ifndef WINCE
	if(errno == EINTR)
		return;
#endif

	general_error(ERROR_IO,tag_fixnum(errno),false_object,NULL);
}

void factor_vm::primitive_fopen()
{
	data_root<byte_array> mode(ctx->pop(),this);
	data_root<byte_array> path(ctx->pop(),this);
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
			ctx->push(allot_alien(file));
			break;
		}
	}
}

FILE *factor_vm::pop_file_handle()
{
	return (FILE *)alien_offset(ctx->pop());
}

void factor_vm::primitive_fgetc()
{
	FILE *file = pop_file_handle();

	for(;;)
	{
		int c = fgetc(file);
		if(c == EOF)
		{
			if(feof(file))
			{
				ctx->push(false_object);
				break;
			}
			else
				io_error();
		}
		else
		{
			ctx->push(tag_fixnum(c));
			break;
		}
	}
}

void factor_vm::primitive_fread()
{
	FILE *file = pop_file_handle();
	fixnum size = unbox_array_size();

	if(size == 0)
	{
		ctx->push(tag<string>(allot_string(0,0)));
		return;
	}

	data_root<byte_array> buf(allot_uninitialized_array<byte_array>(size),this);

	for(;;)
	{
		int c = fread(buf.untagged() + 1,1,size,file);
		if(c <= 0)
		{
			if(feof(file))
			{
				ctx->push(false_object);
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
			ctx->push(buf.value());
			break;
		}
	}
}

void factor_vm::primitive_fputc()
{
	FILE *file = pop_file_handle();
	fixnum ch = to_fixnum(ctx->pop());

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

void factor_vm::primitive_fwrite()
{
	FILE *file = pop_file_handle();
	byte_array *text = untag_check<byte_array>(ctx->pop());
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

void factor_vm::primitive_ftell()
{
	FILE *file = pop_file_handle();
	off_t offset;

	if((offset = FTELL(file)) == -1)
		io_error();

	ctx->push(from_signed_8(offset));
}

void factor_vm::primitive_fseek()
{
	int whence = to_fixnum(ctx->pop());
	FILE *file = pop_file_handle();
	off_t offset = to_signed_8(ctx->pop());

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

void factor_vm::primitive_fflush()
{
	FILE *file = pop_file_handle();
	for(;;)
	{
		if(fflush(file) == EOF)
			io_error();
		else
			break;
	}
}

void factor_vm::primitive_fclose()
{
	FILE *file = pop_file_handle();
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
VM_C_API int err_no()
{
	return errno;
}

VM_C_API void clear_err_no()
{
	errno = 0;
}
}
