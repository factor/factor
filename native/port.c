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

PORT* port(PORT_MODE type, CELL fd)
{
	PORT* port = allot_object(PORT_TYPE,sizeof(PORT));
	port->type = type;
	port->fd = fd;
	port->buffer = NULL;
	port->line = F;
	port->client_host = F;
	port->client_port = F;
	port->client_socket = F;
	port->line = F;
	port->line_ready = false;
	port->buf_fill = 0;
	port->buf_pos = 0;

	if(type == PORT_SPECIAL)
		port->buffer = NULL;
	else
		port->buffer = string(BUF_SIZE,'\0');

	if(fcntl(port->fd,F_SETFL,O_NONBLOCK,1) == -1)
		io_error(__FUNCTION__);

	return port;
}

void init_line_buffer(PORT* port, FIXNUM count)
{
	if(port->line == F)
		port->line = tag_object(sbuf(LINE_SIZE));
	else
		untag_sbuf(port->line)->top = 0;
}

void primitive_portp(void)
{
	drepl(tag_boolean(typep(PORT_TYPE,dpeek())));
}

void fixup_port(PORT* port)
{
	port->fd = -1;
	if(port->buffer != 0)
		port->buffer = fixup_untagged_string(port->buffer);
	fixup(&port->line);
	fixup(&port->client_host);
	fixup(&port->client_port);
}

void collect_port(PORT* port)
{
	if(port->buffer != 0)
		port->buffer = copy_untagged_string(port->buffer);
	copy_object(&port->line);
	copy_object(&port->client_host);
	copy_object(&port->client_port);
}
