#include "master.hpp"

namespace factor
{

s64 current_micros()
{
	FILETIME t;
	GetSystemTimeAsFileTime(&t);
	return (((s64)t.dwLowDateTime | (s64)t.dwHighDateTime<<32)
		- EPOCH_OFFSET) / 10;
}

long exception_handler(PEXCEPTION_POINTERS pe)
{
	PEXCEPTION_RECORD e = (PEXCEPTION_RECORD)pe->ExceptionRecord;
	CONTEXT *c = (CONTEXT*)pe->ContextRecord;

	if(in_code_heap_p(c->EIP))
		signal_callstack_top = (void *)c->ESP;
	else
		signal_callstack_top = NULL;

	if(e->ExceptionCode == EXCEPTION_ACCESS_VIOLATION)
	{
		signal_fault_addr = e->ExceptionInformation[1];
		c->EIP = (cell)memory_signal_handler_impl;
	}
	/* If the Widcomm bluetooth stack is installed, the BTTray.exe process
	injects code into running programs. For some reason this results in
	random SEH exceptions with this (undocumented) exception code being
	raised. The workaround seems to be ignoring this altogether, since that
	is what happens if SEH is not enabled. Don't really have any idea what
	this exception means. */
	else if(e->ExceptionCode != 0x40010006)
	{
		signal_number = e->ExceptionCode;
		c->EIP = (cell)misc_signal_handler_impl;
	}

	return EXCEPTION_CONTINUE_EXECUTION;
}

void c_to_factor_toplevel(cell quot)
{
	if(!AddVectoredExceptionHandler(0, (void*)exception_handler))
		fatal_error("AddVectoredExceptionHandler failed", 0);
	c_to_factor(quot);
	RemoveVectoredExceptionHandler((void*)exception_handler);
}

void open_console()
{
}

}
