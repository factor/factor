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

long exception_handler(PEXCEPTION_RECORD rec, void *frame, void *ctx, void *dispatch)
{
	CONTEXT *c = (CONTEXT*)ctx;
	void *esp = NULL;
	if(in_code_heap_p(c->Eip))
		esp = (void*)c->Esp;
	printf("ExceptionCode = 0x%08x\n", rec->ExceptionCode);
	printf("AccessViolationCode = 0x%08x\n", EXCEPTION_ACCESS_VIOLATION);
	printf("DivideByZeroCode1 = 0x%08x\n", EXCEPTION_FLT_DIVIDE_BY_ZERO);
	printf("DivideByZeroCode2 = 0x%08x\n", EXCEPTION_INT_DIVIDE_BY_ZERO);
	printf("addr=0x%08x\n", rec->ExceptionInformation[1]);
	printf("eax=0x%08x\n", c->Eax);
	printf("eax=0x%08x\n", c->Ebx);
	printf("eip=0x%08x\n", c->Eip);
	printf("esp=0x%08x\n", c->Esp);

	printf("calculated esp: 0x%08x\n", esp);

	if(rec->ExceptionCode == EXCEPTION_ACCESS_VIOLATION)
		memory_protection_error(rec->ExceptionInformation[1], esp);
	else if(rec->ExceptionCode == EXCEPTION_FLT_DIVIDE_BY_ZERO
			|| rec->ExceptionCode == EXCEPTION_INT_DIVIDE_BY_ZERO)
		general_error(ERROR_DIVIDE_BY_ZERO,F,F,esp);
	else
		signal_error(11,esp);
	return -1; /* unreachable */
}

void c_to_factor_toplevel(CELL quot)
{
	exception_record_t record;
	asm volatile("mov %%fs:0, %0" : "=r" (record.next_handler));
	asm volatile("mov %0, %%fs:0" : : "r" (&record));
	record.handler_func = exception_handler;
	c_to_factor(quot);
	asm volatile("mov %0, %%fs:0" : "=r" (record.next_handler));
}
