#include "factor.h"

/* Return true if write was done */
bool write_step(PORT* port)
{
	char* chars = (char*)port->buffer + sizeof(STRING);

	FIXNUM amount = write(port->fd,chars + port->buf_pos,
		port->buf_fill - port->buf_pos);

	if(amount == -1)
	{
		if(errno != EAGAIN)
		{
			postpone_io_error(port,__FUNCTION__);
			return true;
		}
		else
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

	pending_io_error(port);

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

void primitive_add_write_io_task(void)
{
	PORT* port = untag_port(dpop());
	CELL callback = dpop();
	add_io_task(IO_TASK_WRITE,port,callback,
		write_io_tasks,&write_fd_count);
}

bool perform_write_io_task(PORT* port)
{
	if(write_step(port))
	{
		if(port->buf_pos == port->buf_fill || port->io_error != F)
		{
			/* All written, or I/O error is preventing further
			transaction */
			port->buf_pos = 0;
			port->buf_fill = 0;
			return true;
		}
	}
	return false;
}

void write_char_8(PORT* port, FIXNUM ch)
{
	char c = (char)ch;

	if(!can_write(port,1))
		io_error(__FUNCTION__);

	bput((CELL)port->buffer + sizeof(STRING) + port->buf_fill,c);
	port->buf_fill++;
}

void write_string_8(PORT* port, STRING* str)
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

void primitive_write_8(void)
{
	PORT* port = untag_port(dpop());

	CELL text = dpop();
	CELL type = type_of(text);

	pending_io_error(port);

	switch(type)
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		write_char_8(port,to_fixnum(text));
		break;
	case STRING_TYPE:
		write_string_8(port,untag_string(text));
		break;
	default:
		type_error(STRING_TYPE,text);
		break;
	}
}
