#include "factor.h"

/* Return true if something was read */
bool read_step(F_PORT* port)
{
	F_FIXNUM amount = 0;
	F_STRING* buffer = untag_string(port->buffer);
	CELL capacity = buffer->capacity;

	if(port->type == PORT_RECV)
	{
		/* try reading OOB data. */
		amount = recv(port->fd,buffer + 1,capacity * CHARS,MSG_OOB);
	}

	if(amount <= 0)
	{
		amount = read(port->fd,buffer + 1,capacity * CHARS);
	}

	if(amount < 0)
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
		port->buf_fill = (amount < 0 ? 0 : amount);
		port->buf_pos = 0;
		return true;
	}
}

bool read_line_step(F_PORT* port)
{
	int i;
	BYTE ch;

	F_SBUF* line = untag_sbuf(port->line);
	F_STRING* buffer = untag_string(port->buffer);

	for(i = port->buf_pos; i < port->buf_fill; i++)
	{
		ch = bget((CELL)buffer + sizeof(F_STRING) + i);

		if(ch == '\r')
		{
			if(i != port->buf_fill - 1)
			{
				ch = bget((CELL)buffer
					+ sizeof(F_STRING) + i + 1);
				if(ch == '\n')
					i++;
			}

			port->buf_pos = i + 1;
			port->line_ready = true;
			return true;
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

bool can_read_line(F_PORT* port)
{
	pending_io_error(port);

	if(port->type != PORT_READ && port->type != PORT_RECV)
		general_error(ERROR_INCOMPATIBLE_PORT,tag_object(port));

	if(port->line_ready)
		return true;
	else
	{
		init_line_buffer(port,LINE_SIZE);
		read_line_step(port);
		return port->line_ready;
	}
}

void primitive_can_read_line(void)
{
	F_PORT* port = untag_port(dpop());
	box_boolean(can_read_line(port));
}

void primitive_add_read_line_io_task(void)
{
	CELL callback, port;

	maybe_garbage_collection();

	callback = dpop();
	port = dpop();
	add_io_task(IO_TASK_READ_LINE,port,F,callback,
		read_io_tasks,&read_fd_count);

	init_line_buffer(untag_port(port),LINE_SIZE);
}

bool perform_read_line_io_task(F_PORT* port)
{
	if(port->buf_pos >= port->buf_fill)
	{
		if(!read_step(port))
			return false;
	}

	if(port->buf_fill == 0)
	{
		/* EOF */
		if(port->line != F)
		{
			if(untag_sbuf(port->line)->top == 0)
				port->line = F;
		}
		port->line_ready = true;
		return true;
	}
	else
		return read_line_step(port);
}

void primitive_read_line_8(void)
{
	F_PORT* port;

	maybe_garbage_collection();

	port = untag_port(dpeek());

	pending_io_error(port);

	if(port->line_ready)
	{
		drepl(port->line);
		port->line = F;
		port->line_ready = false;
	}
	else
		io_error(__FUNCTION__);

}

bool read_count_step(F_PORT* port)
{
	int i;
	BYTE ch;

	F_SBUF* line = untag_sbuf(port->line);
	F_STRING* buffer = untag_string(port->buffer);

	for(i = port->buf_pos; i < port->buf_fill; i++)
	{
		ch = bget((CELL)buffer + sizeof(F_STRING) + i);
		set_sbuf_nth(line,line->top,ch);
		if(line->top == port->count)
		{
			port->buf_pos = i + 1;
			return true;
		}
	}

	/* We've reached the end of the above loop, without seeing enough chars
	or EOF, so read again */
	port->buf_pos = port->buf_fill;
	return false;
}

bool can_read_count(F_PORT* port, F_FIXNUM count)
{
	pending_io_error(port);

	if(port->type != PORT_READ && port->type != PORT_RECV)
		general_error(ERROR_INCOMPATIBLE_PORT,tag_object(port));

	if(port->line != F && CAN_READ_COUNT(port,count))
		return true;
	else
	{
		port->count = count;
		init_line_buffer(port,count);
		read_count_step(port);
		return CAN_READ_COUNT(port,count);
	}
}

void primitive_can_read_count(void)
{
	F_PORT* port;
	F_FIXNUM len;

	maybe_garbage_collection();

	port = untag_port(dpop());
	len = to_fixnum(dpop());
	box_boolean(can_read_count(port,len));
}

void primitive_add_read_count_io_task(void)
{
	CELL callback;
	F_PORT* port;
	F_FIXNUM count;

	maybe_garbage_collection();

	callback = dpop();
	port = untag_port(dpop());
	count = to_fixnum(dpop());
	add_io_task(IO_TASK_READ_COUNT,
		tag_object(port),F,callback,
		read_io_tasks,&read_fd_count);

	port->count = count;
	init_line_buffer(port,count);
}

bool perform_read_count_io_task(F_PORT* port)
{
	if(port->buf_pos >= port->buf_fill)
	{
		if(!read_step(port))
			return false;
	}

	if(port->buf_fill == 0)
		return true;
	else
		return read_count_step(port);
}

void primitive_read_count_8(void)
{
	F_PORT* port;
	F_FIXNUM len;

	maybe_garbage_collection();

	port = untag_port(dpop());
	len = to_fixnum(dpop());
	if(port->count != len)
		critical_error("read# counts don't match",tag_object(port));

	pending_io_error(port);

	dpush(port->line);
	port->line = F;
	port->line_ready = false;
}
