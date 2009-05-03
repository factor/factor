#include "master.hpp"

s64 current_micros(void)
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

void flush_icache(CELL start, CELL end)
{
	FlushInstructionCache(GetCurrentProcess(), 0, 0);
}

char *getenv(char *name)
{
	not_implemented_error();
	return 0; /* unreachable */
}

void primitive_os_envs(void)
{
	not_implemented_error();
}

void c_to_factor_toplevel(CELL quot)
{
	c_to_factor(quot);
}

void open_console(void) { }
