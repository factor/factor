#include "../factor.h"

/* 
 * Various stubs for functions not currently implemented in the Windows port.
 */

void init_signals(void)
{
}

void primitive_accept_fd(void)
{
	undefined();
}

void primitive_add_accept_io_task(void)
{
	undefined();
}

void primitive_server_socket(void)
{
	undefined();
}

void primitive_client_socket(void)
{
	undefined();
}

void primitive_call_profiling(void)
{
	undefined();
}
