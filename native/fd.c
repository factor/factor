#include "factor.h"

void init_io(void)
{
	env.user[STDIN_ENV]  = tag_object(port(PORT_READ,0));
	env.user[STDOUT_ENV] = tag_object(port(PORT_WRITE,1));
}

bool can_read_line(PORT* port)
{
	if(port->line_ready)
		return true;
	else
	{
		read_line_step(port);
		return port->line_ready;
	}
}

void primitive_can_read_line(void)
{
	PORT* port = untag_port(dpop());
	dpush(tag_boolean(can_read_line(port)));
}

/* Return true if something was read */
bool read_step(PORT* port)
{
	FIXNUM  amount = 0;

	if(port->type == PORT_RECV)
	{
		/* try reading OOB data. */
		amount = recv(port->fd,
			port->buffer + 1,
			port->buffer->capacity * 2,
			MSG_OOB);
	}

	if(amount <= 0)
	{
		amount = read(port->fd,
			port->buffer + 1,
			port->buffer->capacity * 2);
	}

	if(amount < 0)
	{
		if(errno != EAGAIN)
			io_error(__FUNCTION__);
		return false;
	}
	else
	{
		port->buf_fill = (amount < 0 ? 0 : amount);
		port->buf_pos = 0;
		return true;
	}
}

bool read_line_step(PORT* port)
{
	int i;
	char ch;

	SBUF* line;

	if(port->line == F)
	{
		line = sbuf(LINE_SIZE);
		port->line = tag_object(line);
	}
	else
	{
		line = untag_sbuf(port->line);
		line->top = 0;
	}

	for(i = port->buf_pos; i < port->buf_fill; i++)
	{
		ch = bget((CELL)port->buffer + sizeof(STRING) + i);

		if(ch == '\r')
		{
			if(i != port->buf_fill - 1)
			{
				ch = bget((CELL)port->buffer
					+ sizeof(STRING) + i + 1);
				if(ch == '\n')
					i++;
			}
		}

		if(ch == '\n')
		{
			port->buf_pos = i + 1;
			port->line_ready = true;
			return true;
		}
		else
			set_sbuf_nth(line,line->top,ch);
	}

	/* We've reached the end of the above loop, without seeing a newline
	or EOF, so read again */
	port->buf_pos = port->buf_fill;
	port->line_ready = false;
	return false;
}

void primitive_read_line_fd_8(void)
{
	PORT* port = untag_port(dpeek());
	if(port->line_ready)
	{
		drepl(port->line);
		port->line = F;
		port->line_ready = false;
	}
	else
		io_error(__FUNCTION__);

}

/* Return true if write was done */
bool write_step(PORT* port)
{
	char* chars = (char*)port->buffer + sizeof(STRING);

	FIXNUM amount = write(port->fd,chars + port->buf_pos,
		port->buf_fill - port->buf_pos);

	if(amount == -1)
	{
		if(errno != EAGAIN)
			io_error(__FUNCTION__);
		return false;
	}
	else
	{
		port->buf_pos += amount;
		return true;
	}
}

bool can_write(PORT* port, FIXNUM len)
{
	CELL buf_capacity;

	switch(port->type)
	{
	case PORT_READ:
		return false;
	case PORT_WRITE:
		buf_capacity = port->buffer->capacity * CHARS;
		/* Is the string longer than the buffer? */
		if(port->buf_fill == 0 && len > buf_capacity)
		{
			/* Increase the buffer to fit the string */
			port->buffer = allot_string(len / CHARS + 1);
			return true;
		}
		else
			return (port->buf_fill + len <= buf_capacity);
	default:
		critical_error("Bad port->type",port->type);
		return false;
	}
}

void primitive_can_write(void)
{
	PORT* port = untag_port(dpop());
	FIXNUM len = to_fixnum(dpop());
	dpush(tag_boolean(can_write(port,len)));
}

void write_fd_char_8(PORT* port, FIXNUM ch)
{
	char c = (char)ch;

	if(!can_write(port,1))
		io_error(__FUNCTION__);

	bput((CELL)port->buffer + sizeof(STRING) + port->buf_fill,c);
	port->buf_fill++;
}

void write_fd_string_8(PORT* port, STRING* str)
{
	char* c_str;

	/* Note this ensures the buffer is large enough to fit the string */
	if(!can_write(port,str->capacity))
		io_error(__FUNCTION__);

	c_str = to_c_string(str);

	/* Append string to buffer */
	memcpy((void*)((CELL)port->buffer + sizeof(STRING)
		+ port->buf_fill),c_str,str->capacity);

	port->buf_fill += str->capacity;
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

void primitive_close_fd(void)
{
	/* This does not flush. */
	PORT* port = untag_port(dpop());
	close(port->fd);
}
