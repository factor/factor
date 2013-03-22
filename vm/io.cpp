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
	if(errno == EINTR)
		return;

	general_error(ERROR_IO,tag_fixnum(errno),false_object);
}

FILE *factor_vm::safe_fopen(char *filename, char *mode)
{
	FILE *file;
	for(;;)
	{
		file = fopen(filename,mode);
		if(file == NULL)
			io_error();
		else
			break;
	}
	return file;
}

int factor_vm::safe_fgetc(FILE *stream)
{
	int c;
	for(;;)
	{
		c = getc(stream);
		if(c == EOF)
		{
			if(feof(stream))
				return EOF;
			else
				io_error();
		}
		else
			break;
	}
	return c;
}

size_t factor_vm::safe_fread(void *ptr, size_t size, size_t nitems, FILE *stream)
{
	size_t items_read = 0;
	size_t ret = 0;

	do
	{
		ret = fread((void*)((int*)ptr+items_read*size),size,nitems-items_read,stream);
		if(ret == 0)
		{
			if(feof(stream))
				break;
			else
				io_error();
		}
		items_read += ret;
	} while(items_read != nitems);

	return items_read;
}

void factor_vm::safe_fputc(int c, FILE *stream)
{
	for(;;)
	{
		if(putc(c,stream) == EOF)
			io_error();
		else
			break;
	}
}

size_t factor_vm::safe_fwrite(void *ptr, size_t size, size_t nitems, FILE *stream)
{
	size_t items_written = 0;
	size_t ret = 0;

	do {
		ret = fwrite((void*)((int*)ptr+items_written*size),size,nitems-items_written,stream);
		if(ret == 0)
			io_error();
		items_written += ret;
	} while(items_written != nitems);

	return items_written;
}

int factor_vm::safe_ftell(FILE *stream)
{
	off_t offset;
	for(;;)
	{
		if((offset = FTELL(stream)) == -1)
			io_error();
		else
			break;
	}
	return offset;
}

void factor_vm::safe_fseek(FILE *stream, off_t offset, int whence)
{
	switch(whence)
	{
	case 0: whence = SEEK_SET; break;
	case 1: whence = SEEK_CUR; break;
	case 2: whence = SEEK_END; break;
	default:
		critical_error("Bad value for whence",whence);
	}

	for(;;)
	{
		if(FSEEK(stream,offset,whence) == -1)
			io_error();
		else
			break;
	}
}

void factor_vm::safe_fflush(FILE *stream)
{
	for(;;)
	{
		if(fflush(stream) == EOF)
			io_error();
		else
			break;
	}
}

void factor_vm::safe_fclose(FILE *stream)
{
	for(;;)
	{
		if(fclose(stream) == EOF)
			io_error();
		else
			break;
	}
}

void factor_vm::primitive_fopen()
{
	data_root<byte_array> mode(ctx->pop(),this);
	data_root<byte_array> path(ctx->pop(),this);
	mode.untag_check(this);
	path.untag_check(this);

	FILE *file;
	file = safe_fopen((char *)(path.untagged() + 1),
		(char *)(mode.untagged() + 1));
	ctx->push(allot_alien(file));
}

FILE *factor_vm::pop_file_handle()
{
	return (FILE *)alien_offset(ctx->pop());
}

FILE *factor_vm::peek_file_handle()
{
	return (FILE *)alien_offset(ctx->peek());
}

void factor_vm::primitive_fgetc()
{
	FILE *file = peek_file_handle();

	int c = safe_fgetc(file);
	if(c == EOF && feof(file))
	{
		clearerr(file);
		ctx->replace(false_object);
	}
	else
		ctx->replace(tag_fixnum(c));
}

/* Allocates memory */
void factor_vm::primitive_fread()
{
	FILE *file = pop_file_handle();
	void *buf = (void*)alien_offset(ctx->peek());
	fixnum size = unbox_array_size();

	if(size == 0)
	{
		ctx->replace(from_unsigned_cell(0));
		return;
	}

	size_t c = safe_fread(buf,1,size,file);
	if(c == 0 || feof(file))
		clearerr(file);
	ctx->replace(from_unsigned_cell(c));
}

void factor_vm::primitive_fputc()
{
	FILE *file = pop_file_handle();
	fixnum ch = to_fixnum(ctx->pop());
	safe_fputc((int)ch, file);
}

void factor_vm::primitive_fwrite()
{
	FILE *file = pop_file_handle();
	cell length = to_cell(ctx->pop());
	char *text = alien_offset(ctx->pop());

	if(length == 0)
		return;

	size_t written = safe_fwrite(text,1,length,file);
	if(written != length)
		io_error();
}

void factor_vm::primitive_ftell()
{
	FILE *file = peek_file_handle();
	ctx->replace(from_signed_8(safe_ftell(file)));
}

void factor_vm::primitive_fseek()
{
	FILE *file = pop_file_handle();
	int whence = (int)to_fixnum(ctx->pop());
	off_t offset = (off_t)to_signed_8(ctx->pop());
	safe_fseek(file,offset,whence);
}

void factor_vm::primitive_fflush()
{
	FILE *file = pop_file_handle();
	safe_fflush(file);
}

void factor_vm::primitive_fclose()
{
	FILE *file = pop_file_handle();
	safe_fclose(file);
}

/* This function is used by FFI I/O. Accessing the errno global directly is
not portable, since on some libc's errno is not a global but a funky macro that
reads thread-local storage. */
VM_C_API int err_no()
{
	return errno;
}

VM_C_API void set_err_no(int err)
{
	errno = err;
}
}
