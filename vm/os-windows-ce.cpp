#include "master.hpp"

namespace factor
{

s64 current_micros()
{
	SYSTEMTIME st;
	FILETIME ft;
	GetSystemTime(&st);
	SystemTimeToFileTime(&st, &ft);
	return (((s64)ft.dwLowDateTime
		| (s64)ft.dwHighDateTime<<32) - EPOCH_OFFSET) / 10;
}

char *strerror(int err)
{
	/* strerror() is not defined on WinCE */
	return "strerror() is not defined on WinCE. Use native I/O.";
}

void flush_icache(cell start, cell end)
{
	FlushInstructionCache(GetCurrentProcess(), 0, 0);
}

char *getenv(char *name)
{
	vm->not_implemented_error();
	return 0; /* unreachable */
}

void c_to_factor_toplevel(cell quot)
{
	c_to_factor(quot,vm);
}

void open_console() { }

}
