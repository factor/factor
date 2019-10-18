#include "master.h"

s64 current_millis(void)
{
	SYSTEMTIME st;
	FILETIME ft;
	GetSystemTime(&st);
	SystemTimeToFileTime(&st, &ft);
	return (((s64)ft.dwLowDateTime
		| (s64)ft.dwHighDateTime<<32) - EPOCH_OFFSET) / 10000;
}

DEFINE_PRIMITIVE(cwd)
{
	not_implemented_error();
}

DEFINE_PRIMITIVE(cd)
{
	not_implemented_error();
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

DEFINE_PRIMITIVE(os_envs)
{
	not_implemented_error();
}

void c_to_factor_toplevel(CELL quot)
{
	c_to_factor(quot);
}

void open_console(void) { }
