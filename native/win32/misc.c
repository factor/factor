#include "../factor.h"

/* 
 * Various stubs for functions not currently implemented in the Windows port.
 */

void init_signals(void)
{
}

void primitive_accept_fd(F_WORD *word)
{
	undefined(word);
}

void primitive_add_accept_io_task(F_WORD *word)
{
	undefined(word);
}

void primitive_server_socket(F_WORD *word)
{
	undefined(word);
}

void primitive_client_socket(F_WORD *word)
{
	undefined(word);
}

void primitive_call_profiling(F_WORD *word)
{
	undefined(word);
}
