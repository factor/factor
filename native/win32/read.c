#include "../factor.h"

void primitive_add_read_count_io_task (void)
{
	callback_list = cons(dpop(), callback_list); 
	dpop(); dpop();
}

void primitive_add_read_line_io_task (void)
{
	dpop(); dpop();
}

void primitive_can_read_count (void)
{
	dpop(); dpop();
	box_boolean(true);
}

void primitive_can_read_line (void)
{
	dpop();
	box_boolean(true);
}

void primitive_read_count_8 (void)
{
	F_PORT *port;
	F_FIXNUM len;
	DWORD out_len;
	char *buf;
	F_SBUF *result;
	unsigned int i;

	maybe_garbage_collection();

	port = untag_port(dpop());
	len = to_fixnum(dpop());
	buf = malloc(len);

	if (!ReadFile((HANDLE)port->fd, buf, len, &out_len, NULL))
		io_error(__FUNCTION__);
	
	result = sbuf(out_len);
	
	for (i = 0; i < out_len; ++i)
		set_sbuf_nth(result, i, buf[i] & 0xFF);

	free(buf);
	dpush(tag_object(result));
}

static void fill_buffer(PORT *port)
{
	DWORD read_len;

	if (port->buf_pos)
		return;

	if (!ReadFile((HANDLE)port->fd, port->buf, BUF_SIZE, &read_len, NULL))
		io_error(__FUNCTION__);

	port->buf_pos += read_len;
}

static void unfill_buffer(PORT *port, int len)
{
	memmove(port->buf, port->buf+len, port->buf_pos - len);
	port->buf_pos -= len;
}

void primitive_read_line_8 (void)
{
	F_PORT *port;
	F_SBUF *result;
	int i;
	bool got_line = false;

	maybe_garbage_collection();

	port = untag_port(dpop());

	result = sbuf(0);
	while (!got_line)
	{
		fill_buffer(port);
		for (i = 0; i < port->buf_pos; ++i)
		{
			if (port->buf[i] == '\r') 
			{
				got_line = true;
				if (i < port->buf_pos - 1 && port->buf[i+1] == '\n')
					++i;
				++i;
				break;
			}
			else if (port->buf[i] == '\n')
			{
				got_line = true;
				if (i < port->buf_pos - 1 && port->buf[i+1] == '\r')
					++i;
				++i;
				break;
			}

			set_sbuf_nth(result, result->top, port->buf[i]);
		}

		if (i == 0)
			got_line = true;
		else
			unfill_buffer(port, i);
	}

	if (result->top || i)
		dpush(tag_object(result));
	else
		dpush(F);
}
