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

static void fill_buffer(F_PORT *port)
{
	DWORD read_len;
	F_STRING *buffer = untag_string(port->buffer);

	if (port->buf_pos)
		return;

	if (!ReadFile((HANDLE)port->fd, buffer+1, BUF_SIZE, &read_len, NULL))
		io_error(__FUNCTION__);

	port->buf_pos += read_len;
}

static void unfill_buffer(F_PORT *port, int len)
{
	F_STRING *buffer = untag_string(port->buffer);

	memmove(buffer+1, ((char *)(buffer+1))+len, port->buf_pos - len);
	port->buf_pos -= len;
}

#define GETBUF(n) (bget((CELL)buffer + sizeof(F_STRING) + (n)))

void primitive_read_line_8 (void)
{
	F_PORT *port;
	F_SBUF *result;
	F_STRING *buffer;
	int i;
	bool got_line = false;

	maybe_garbage_collection();

	port = untag_port(dpop());
	buffer = untag_string(port->buffer);
	result = sbuf(LINE_SIZE);

	while (!got_line)
	{
		fill_buffer(port);

		for (i = 0; i < port->buf_pos; ++i)
		{
			BYTE ch = GETBUF(i);

			if (ch == '\r') 
			{
				got_line = true;
				if (i < port->buf_pos - 1 && GETBUF(i+1) == '\n')
					++i;
				++i;
				break;
			}
			else if (ch == '\n')
			{
				got_line = true;
				if (i < port->buf_pos - 1 && GETBUF(i+1) == '\r')
					++i;
				++i;
				break;
			}

			set_sbuf_nth(result, result->top, ch);
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

#undef GETBUF
