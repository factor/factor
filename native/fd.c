#include "factor.h"

void init_io(void)
{
	env.user[STDIN_ENV]  = port(0);
	env.user[STDOUT_ENV] = port(1);
	env.user[STDERR_ENV] = port(2);
}

int read_step(PORT* port, STRING* buf)
{
	int amount = read(port->fd,buf + 1,buf->capacity * 2);

	port->buf_fill = (amount < 0 ? 0 : amount);
	port->buf_pos = 0;

	return amount;
}

void primitive_read_line_fd_8(void)
{
	PORT* port = untag_port(dpeek());

	int amount;
	int i;
	int ch;

	/* finished line, unicode */
	SBUF* line = sbuf(LINE_SIZE);

	init_buffer(port,B_READ);

	for(;;)
	{
		if(port->buf_pos >= port->buf_fill)
		{
			amount = read_step(port,port->buffer);

			if(amount < 0)
				io_error(__FUNCTION__);

			if(amount == 0)
			{
				if(line->top == 0)
				{
					/* didn't read anything before EOF */
					drepl(F);
				}
				else
					drepl(tag_object(line));
				return;
			}
		}

		for(i = port->buf_pos; i < port->buf_fill; i++)
		{
			ch = bget((CELL)port->buffer + sizeof(STRING) + i);
			if(ch == '\n')
			{
				port->buf_pos = i + 1;
				drepl(tag_object(line));
				return;
			}
			else
				set_sbuf_nth(line,line->top,ch);
		}
		
		/* We've reached the end of the above loop */
		port->buf_pos = port->buf_fill;
	}
}

/* keep writing to the stream until everything is written */
void write_fully(PORT* port, char* str, CELL len)
{
	FIXNUM amount, written = 0, remains;

	for(;;)
	{
		remains = len - written;

		if(remains == 0)
			break;

		amount = write(port->fd,str + written,remains);
		if(amount < 0)
			io_error(__FUNCTION__);

		written += amount;
	}
}

void flush_buffer(PORT* port)
{
	if(port->buf_mode != B_WRITE || port->buf_fill == 0)
		return;

	write_fully(port,(char*)port->buffer + sizeof(STRING),port->buf_fill);
	port->buf_fill = 0;
}

void write_fd_char_8(PORT* port, FIXNUM ch)
{
	char c = (char)ch;

	init_buffer(port,B_WRITE);

	/* Is the buffer full? */
	if(port->buf_fill == port->buffer->capacity * CHARS)
		flush_buffer(port);

	bput((CELL)port->buffer + sizeof(STRING) + port->buf_fill,c);
	port->buf_fill++;
}

void write_fd_string_8(PORT* port, STRING* str)
{
	char* c_str = to_c_string(str);

	init_buffer(port,B_WRITE);

	/* Is the string longer than the buffer? */
	if(str->capacity > port->buffer->capacity * CHARS)
	{
		/* Just write it immediately */
		flush_buffer(port);
		write_fully(port,c_str,str->capacity);
	}
	else
	{
		/* Is there enough room in the buffer? If not, flush */
		if(port->buf_fill + str->capacity
			> port->buffer->capacity * CHARS)
		{
			flush_buffer(port);
		}

		/* Append string to buffer */
		memcpy((void*)((CELL)port->buffer + sizeof(STRING)
			+ port->buf_fill),c_str,str->capacity);

		port->buf_fill += str->capacity;
	}
}

void primitive_write_fd_8(void)
{
	PORT* port = untag_port(dpop());

	CELL text = dpop();
	CELL type = type_of(text);

	switch(type)
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		write_fd_char_8(port,to_fixnum(text));
		break;
	case STRING_TYPE:
		write_fd_string_8(port,untag_string(text));
		break;
	default:
		type_error(STRING_TYPE,text);
		break;
	}
}

void primitive_flush_fd(void)
{
	PORT* port = untag_port(dpop());
	flush_buffer(port);
}

void primitive_close_fd(void)
{
	PORT* port = untag_port(dpop());
	flush_buffer(port);
	close(port->fd);
}
