#include "../factor.h"

HANDLE completion_port = INVALID_HANDLE_VALUE;
CELL callback_list = F;

void init_io (void) 
{
	completion_port = CreateIoCompletionPort(
		INVALID_HANDLE_VALUE, NULL, 0, 1);

	if (completion_port == INVALID_HANDLE_VALUE)
		io_error(__FUNCTION__);

	userenv[STDIN_ENV] = tag_object(port(PORT_READ, (CELL)GetStdHandle(STD_INPUT_HANDLE)));
	userenv[STDOUT_ENV] = tag_object(port(PORT_WRITE, (CELL)GetStdHandle(STD_OUTPUT_HANDLE)));
}

void primitive_add_copy_io_task (void)
{
	io_error(__FUNCTION__);
}

void primitive_close (void)
{
	PORT *port = untag_port(dpop());
	CloseHandle((HANDLE)port->fd);
	port->closed = true;
}

void primitive_next_io_task (void)
{
	if (callback_list != F)
	{
		CONS *cons = untag_cons(callback_list);
		CELL car = cons->car;
		callback_list = cons->cdr;
		dpush(car);
	}
	else
		dpush(F);
}

void collect_io_tasks (void)
{
	copy_object(&callback_list);
}