#include "master.h"

s64 current_millis(void)
{
	FILETIME t;
	GetSystemTimeAsFileTime(&t);
	return (((s64)t.dwLowDateTime | (s64)t.dwHighDateTime<<32)
		- EPOCH_OFFSET) / 10000;
}

void primitive_cwd(void)
{
	F_CHAR buf[MAX_PATH + 4];

	if(!GetCurrentDirectory(MAX_PATH + 4, buf))
		io_error();

	box_u16_string(buf);
}

void primitive_cd(void)
{
	SetCurrentDirectory(unbox_u16_string());
}

void seh_call(void (*func)(), exception_handler_t *handler)
{
	exception_record_t record;
	asm volatile("mov %%fs:0, %0" : "=r" (record.next_handler));
	asm volatile("mov %0, %%fs:0" : : "r" (&record));
	record.handler_func = handler;
	func();
	asm volatile("mov %0, %%fs:0" : "=r" (record.next_handler));
}

long exception_handler(PEXCEPTION_RECORD rec, void *frame, void *ctx, void *dispatch)
{
	memory_protection_error(
		rec->ExceptionInformation[1],
		native_stack_pointer());
	return -1; /* unreachable */
}

void run_toplevel(void)
{
	seh_call(run, exception_handler);
}
