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

CELL port(CELL fd)
{
	PORT* port = allot_object(PORT_TYPE,sizeof(PORT));
	port->fd = fd;
	port->buffer = (STRING*)0;
	port->buf_mode = B_NONE;
	port->buf_fill = 0;
	port->buf_pos = 0;
	return tag_object(port);
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
	}
}

void fixup_port(PORT* port)
{
	port->fd = -1;
	if(port->buffer != 0)
	{
		port->buffer = (STRING*)((CELL)port->buffer
			+ (active->base - relocation_base));
	}
}

void collect_port(PORT* port)
{
	if(port->buffer != 0)
	{
		port->buffer = copy_untagged_object(
			port->buffer,SSIZE(port->buffer));
	}
}
