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
	return "strerror() is not defined on WinCE. Use native io";
}

void flush_icache()
{
	FlushInstructionCache(GetCurrentProcess(), 0, 0);
}

char *getenv(char *name)
{
	not_implemented_error();
	return 0; /* unreachable */
}

long exception_handler(PEXCEPTION_RECORD rec, void *frame, void *ctx, void *dispatch)
{
	memory_protection_error(
		rec->ExceptionInformation[1] & 0x1ffffff,
		native_stack_pointer());
	return -1; /* unreachable */
}
