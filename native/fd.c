#include "factor.h"

void init_io(void)
{
	env.user[STDIN_ENV]  = handle(HANDLE_FD,0);
	env.user[STDOUT_ENV] = handle(HANDLE_FD,1);
	env.user[STDERR_ENV] = handle(HANDLE_FD,2);
}

void init_buffer(HANDLE* h, int mode)
{
	if(h->buf_mode == B_NONE)
		h->buffer = tag_object(string(BUF_SIZE,'\0'));
	if(h->buf_mode != mode)
	{
		h->buf_fill = h->buf_pos = 0;
		h->buf_mode = mode;
	}
}

int fill_buffer(HANDLE* h, int fd, STRING* buf)
{
	int amount = read(fd,buf + 1,buf->capacity * 2);
	/* printf("READING %d GOT %d\n",buf->capacity * 2,amount); */

	h->buf_fill = (amount < 0 ? 0 : amount);
	h->buf_pos = 0;

	return amount;
}

void primitive_read_line_fd_8(void)
{
	HANDLE* h = untag_handle(HANDLE_FD,env.dt);
	int fd = h->object;

	int amount;
	int i;
	int ch;

	/* finished line, unicode */
	SBUF* line = sbuf(LINE_SIZE);

	/* read ascii from fd */
	STRING* buf;

	init_buffer(h,B_READ);

	buf = untag_string(h->buffer);

	for(;;)
	{
		if(h->buf_pos >= h->buf_fill)
		{
			amount = fill_buffer(h,fd,buf);

			if(amount < 0)
				io_error(__FUNCTION__);

			if(amount == 0)
			{
				if(line->top == 0)
				{
					/* didn't read anything before EOF */
					env.dt = F;
				}
				else
					env.dt = tag_object(line);
				return;
			}
		}

		for(i = h->buf_pos; i < h->buf_fill; i++)
		{
			ch = bget((CELL)buf + sizeof(STRING) + i);
			if(ch == '\n')
			{
				h->buf_pos = i + 1;
				env.dt = tag_object(line);
				return;
			}
			else
				set_sbuf_nth(line,line->top,ch);
		}
		
		/* We've reached the end of the above loop */
		h->buf_pos = h->buf_fill;
	}
}

/* keep writing to the stream until everything is written */
void write_fully(HANDLE* h, char* str, CELL len)
{
	FIXNUM amount, written = 0, remains;

	for(;;)
	{
		remains = len - written;

		if(remains == 0)
			break;

		amount = write(h->object,str + written,remains);
		if(amount < 0)
			io_error(__FUNCTION__);

		written += amount;
	}
}

void flush_buffer(HANDLE* h)
{
	STRING* buf;

	if(h->buf_mode != B_WRITE || h->buf_fill == 0)
		return;

	buf = untag_string(h->buffer);

	write_fully(h,(char*)buf + sizeof(STRING),h->buf_fill);
	h->buf_fill = 0;
}

void write_fd_char_8(HANDLE* h, FIXNUM ch)
{
	char c = (char)ch;
	STRING* buf;

	init_buffer(h,B_WRITE);
	buf = untag_string(h->buffer);

	/* Is the buffer full? */
	if(h->buf_fill == buf->capacity * CHARS)
		flush_buffer(h);

	bput((CELL)buf + sizeof(STRING) + h->buf_fill,c);
	h->buf_fill++;
}

void write_fd_string_8(HANDLE* h, STRING* str)
{
	char* c_str = to_c_string(str);
	STRING* buf;

	init_buffer(h,B_WRITE);
	buf = untag_string(h->buffer);

	/* Is the string longer than the buffer? */
	if(str->capacity > buf->capacity * CHARS)
	{
		/* Just write it immediately */
		flush_buffer(h);
		write_fully(h,c_str,str->capacity);
	}
	else
	{
		/* Is there enough room in the buffer? If not, flush */
		if(h->buf_fill + str->capacity > buf->capacity * CHARS)
			flush_buffer(h);

		/* Append string to buffer */
		memcpy((void*)((CELL)buf + sizeof(STRING) + h->buf_fill),
			c_str,str->capacity);

		h->buf_fill += str->capacity;
	}
}

void primitive_write_fd_8(void)
{
	HANDLE* h = untag_handle(HANDLE_FD,env.dt);

	CELL text = dpop();
	CELL type = type_of(text);

	switch(type)
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		write_fd_char_8(h,to_fixnum(text));
		break;
	case STRING_TYPE:
		write_fd_string_8(h,untag_string(text));
		break;
	default:
		type_error(STRING_TYPE,text);
		break;
	}

	env.dt = dpop();
}

void primitive_flush_fd(void)
{
	HANDLE* h = untag_handle(HANDLE_FD,env.dt);
	flush_buffer(h);

	env.dt = dpop();
}

void primitive_close_fd(void)
{
	HANDLE* h = untag_handle(HANDLE_FD,env.dt);
	flush_buffer(h);
	close(h->object);
	env.dt = dpop();
}
