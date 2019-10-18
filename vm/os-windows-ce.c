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

void primitive_cwd(void)
{
	primitive_error();
}

void primitive_cd(void)
{
	primitive_error();
}

char *strerror(int err)
{
	/* strerror() is not defined on WinCE */
	return "unknown error (TODO: Native I/O)";
}

void flush_icache()
{
	FlushInstructionCache(GetCurrentProcess(), 0, 0);
}

char *getenv(char *name)
{
	primitive_error();
	return 0; /* unreachable */
}

long exception_handler(PEXCEPTION_RECORD rec, void *frame, void *ctx, void *dispatch)
{
	// CE returns 0x21201000, but real ptr is at 0x1201000
	memory_protection_error(
		rec->ExceptionInformation[1] & 0xfffffff,
		native_stack_pointer());
	return -1; /* unreachable */
}
