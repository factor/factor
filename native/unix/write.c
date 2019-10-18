#include "../factor.h"

/* Return true if write was done */
void write_step(F_PORT* port)
{
	BYTE* chars = (BYTE*)untag_string(port->buffer) + sizeof(F_STRING);

	F_FIXNUM amount = write(port->fd,chars + port->buf_pos,
		port->buf_fill - port->buf_pos);

	if(amount == -1)
	{
		if(errno != EAGAIN)
			postpone_io_error(port,__FUNCTION__);
	}
	else
		port->buf_pos += amount;
}

bool can_write(F_PORT* port, F_FIXNUM len)
{
	CELL buf_capacity;

	if(port->type != PORT_WRITE)
		general_error(ERROR_INCOMPATIBLE_PORT,tag_object(port));

	buf_capacity = untag_string(port->buffer)->capacity * CHARS;
	/* Is the string longer than the buffer? */
	if(port->buf_fill == 0 && len > buf_capacity)
	{
		/* Increase the buffer to fit the string */
		port->buffer = tag_object(allot_string(len / CHARS + 1));
		return true;
	}
	else
		return (port->buf_fill + len <= buf_capacity);
}

void primitive_can_write(void)
{
	F_PORT* port;
	F_FIXNUM len;

	maybe_garbage_collection();
	
	port = untag_port(dpop());
	len = to_fixnum(dpop());
	pending_io_error(port);
	box_boolean(can_write(port,len));
}

void primitive_add_write_io_task(void)
{
	CELL callback, port;

	maybe_garbage_collection();

	callback = dpop();
	port = dpop();
	add_io_task(IO_TASK_WRITE,port,F,callback,
		write_io_tasks,&write_fd_count);
}

bool perform_write_io_task(F_PORT* port)
{
	if(port->buf_pos == port->buf_fill || port->io_error != F)
	{
		/* Nothing to write */
		port->buf_pos = 0;
		port->buf_fill = 0;
		return true;
	}
	else
	{
		write_step(port);
		return false;
	}
}

void write_char_8(F_PORT* port, F_FIXNUM ch)
{
	BYTE c = (BYTE)ch;

	pending_io_error(port);

	if(!can_write(port,1))
		io_error(__FUNCTION__);

	bput((CELL)untag_string(port->buffer) + sizeof(F_STRING) + port->buf_fill,c);
	port->buf_fill++;
}

/* Caller must ensure buffer is of the right size. */
void write_string_raw(F_PORT* port, BYTE* str, CELL len)
{
	/* Append string to buffer */
	memcpy((void*)((CELL)untag_string(port->buffer) + sizeof(F_STRING)
		+ port->buf_fill),str,len);

	port->buf_fill += len;
}

void write_string_8(F_PORT* port, F_STRING* str)
{
	BYTE* c_str;
	
	pending_io_error(port);

	/* Note this ensures the buffer is large enough to fit the string */
	if(!can_write(port,str->capacity))
		io_error(__FUNCTION__);

	c_str = to_c_string_unchecked(str);
	write_string_raw(port,c_str,str->capacity);
}

void primitive_write_8(void)
{
	F_PORT* port;
	CELL text, type;
	F_STRING* str;

	maybe_garbage_collection();

	port = untag_port(dpop());

	text = dpop();
	type = type_of(text);

	pending_io_error(port);

	switch(type)
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		write_char_8(port,to_fixnum(text));
		break;
	case STRING_TYPE:
		str = untag_string(text);
		write_string_8(port,str);
		break;
	default:
		type_error(TEXT_TYPE,text);
		break;
	}
}
