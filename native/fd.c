#include "factor.h"

void init_io(void)
{
	env.user[STDIN_ENV]  = port(0);
	set_nonblocking(0);
	env.user[STDOUT_ENV] = port(1);
	set_nonblocking(1);
	env.user[STDERR_ENV] = port(2);
	/* set_nonblocking(2); */
}

/* Return true if something was read */
bool read_step(PORT* port)
{
	FIXNUM amount = read(port->fd,
		port->buffer + 1,
		port->buffer->capacity * 2);

	if(amount == -1)
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

READLINE_STAT read_line_step(PORT* port)
{
	int i;
	char ch;

	SBUF* line = port->line;

	if(port->buf_pos >= port->buf_fill)
	{
		if(!read_step(port))
			return READLINE_WAIT;

		if(port->buf_fill == 0)
			return READLINE_EOF;
	}

	for(i = port->buf_pos; i < port->buf_fill; i++)
	{
		ch = bget((CELL)port->buffer + sizeof(STRING) + i);
		if(ch == '\n')
		{
			port->buf_pos = i + 1;
			return READLINE_EOL;
		}
		else
			set_sbuf_nth(line,line->top,ch);
	}

	port->buf_pos = port->buf_fill;

	/* We've reached the end of the above loop, without seeing a newline
	or EOF, so read again */
	return READLINE_AGAIN;
}

void primitive_read_line_fd_8(void)
{
	PORT* port = untag_port(dpeek());
	SBUF* line;
	READLINE_STAT state;

	init_buffer(port,B_READ);
	if(port->line == NULL)
		port->line = sbuf(LINE_SIZE);
	else
		port->line->top = 0;
	line = port->line;

	add_io_task(IO_TASK_READ_LINE,port,F);

	for(;;)
	{
		state = read_line_step(port);
		if(state == READLINE_WAIT)
			iomux();
		else if(state == READLINE_EOF && line->top == 0)
		{
			/* didn't read anything before EOF */
			drepl(F);
			break;
		}
		else if(state == READLINE_EOL)
		{
			drepl(tag_object(sbuf_to_string(line)));
			break;
		}
	}

	remove_io_task(IO_TASK_READ_LINE,port);
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

/* keep writing to the stream until everything is written */
void flush_buffer(PORT* port)
{
	IO_TASK* task;
	if(port->buf_mode != B_WRITE || port->buf_fill == 0)
		return;

	task = add_io_task(IO_TASK_WRITE,port,F);

	for(;;)
	{
		if(port->buf_fill == port->buf_pos)
			break;

		if(!write_step(port))
			iomux();
	}

	remove_io_task(IO_TASK_WRITE,port);

	port->buf_pos = 0;
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
		flush_buffer(port);

		/* Increase the buffer to fit the string */
		port->buffer = allot_string(str->capacity / CHARS + 1);
	}
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

void set_nonblocking(int fd)
{
	if(fcntl(fd,F_SETFL,O_NONBLOCK,1) == -1)
		io_error(__FUNCTION__);
}
