#include "../factor.h"

void primitive_add_write_io_task (void)
{
	maybe_garbage_collection();

	callback_list = cons(dpop(), callback_list); 
	dpop();
}

void primitive_can_write (void)
{
	dpop(); dpop();
	box_boolean(true);
}

void write_char_8 (F_PORT *port, F_FIXNUM ch)
{
	DWORD ignore;
	BYTE buf = (BYTE)ch;
	WriteFile((HANDLE)port->fd, &buf, 1, &ignore, NULL);
}

void write_string_8 (F_PORT *port, F_STRING *str)
{
	DWORD ignore;
	WriteFile((HANDLE)port->fd, to_c_string_unchecked(str), str->capacity, &ignore, NULL);
}

void primitive_write_8 (void)
{
	F_PORT *port;
	CELL text, type;

	maybe_garbage_collection();

	port = untag_port(dpop());
	text = dpop();
	type = type_of(text);

	switch (type)
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
		write_char_8(port, to_fixnum(text));
		break;
	case STRING_TYPE:
		write_string_8(port, untag_string(text));
		break;
	default:
		type_error(TEXT_TYPE, text);
		break;
	}
}
