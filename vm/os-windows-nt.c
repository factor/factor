#include "master.h"

s64 current_millis(void)
{
	FILETIME t;
	GetSystemTimeAsFileTime(&t);
	return (((s64)t.dwLowDateTime | (s64)t.dwHighDateTime<<32)
		- EPOCH_OFFSET) / 10000;
}

DEFINE_PRIMITIVE(cwd)
{
	F_CHAR buf[MAX_PATH + 4];

	if(!GetCurrentDirectory(MAX_PATH + 4, buf))
		io_error();

	box_u16_string(buf);
}

DEFINE_PRIMITIVE(cd)
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
	if(rec->ExceptionCode == EXCEPTION_ACCESS_VIOLATION)
		memory_protection_error(
			rec->ExceptionInformation[1],
			native_stack_pointer());
	else if(rec->ExceptionCode == EXCEPTION_FLT_DIVIDE_BY_ZERO
			|| rec->ExceptionCode == EXCEPTION_INT_DIVIDE_BY_ZERO)
		general_error(ERROR_DIVIDE_BY_ZERO,F,F,false,(void*)rec->ExceptionInformation[1]);
	else
		signal_error(11,(void*)rec->ExceptionInformation[1]);
	return -1; /* unreachable */
}

void run_toplevel(void)
{
	seh_call(run, exception_handler);
}
