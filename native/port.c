#include "factor.h"

PORT* untag_port(CELL tagged)
{
	PORT* p;
	type_check(PORT_TYPE,tagged);
	p = (PORT*)UNTAG(tagged);
	/* after image load & save, ports are no longer valid */
	if(p->fd == -1)
		general_error(ERROR_PORT_EXPIRED,tagged);
	return p;
}

PORT* port(CELL fd)
{
	PORT* port = allot_object(PORT_TYPE,sizeof(PORT));
	port->fd = fd;
	port->buffer = NULL;
	port->line = F;
	port->buf_mode = B_NONE;
	port->buf_fill = 0;
	port->buf_pos = 0;

	if(fcntl(port->fd,F_SETFL,O_NONBLOCK,1) == -1)
		io_error(port,__FUNCTION__);

	return port;
}

void primitive_portp(void)
{
	drepl(tag_boolean(typep(PORT_TYPE,dpeek())));
}

void init_buffer(PORT* port, int mode)
{
	if(port->buf_mode == B_NONE)
		port->buffer = string(BUF_SIZE,'\0');

	if(port->buf_mode != mode)
	{
		port->buf_fill = port->buf_pos = 0;
		port->buf_mode = mode;

		if(mode == B_READ_LINE)
			port->line = tag_object(sbuf(LINE_SIZE));
	}
	else if(port->buf_mode == B_READ_LINE)
	{
		if(port->line == F)
			port->line = tag_object(sbuf(LINE_SIZE));
		else
			untag_sbuf(port->line)->top = 0;
	}
}

void fixup_port(PORT* port)
{
	port->fd = -1;
	if(port->buffer != 0)
		port->buffer = fixup_untagged_string(port->buffer);
	fixup(&port->line);
}

void collect_port(PORT* port)
{
	if(port->buffer != 0)
		port->buffer = copy_untagged_string(port->buffer);
	copy_object(&port->line);
}
