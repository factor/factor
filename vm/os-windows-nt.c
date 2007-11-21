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

DEFINE_PRIMITIVE(os_envs)
{
	GROWABLE_ARRAY(result);

	TCHAR *env = GetEnvironmentStrings();
	TCHAR *finger = env;

	for(;;)
	{
		TCHAR *scan = finger;
		while(*scan != '\0')
			scan++;
		if(scan == finger)
			break;

		REGISTER_UNTAGGED(result);
		CELL string = tag_object(from_u16_string(finger));
		UNREGISTER_UNTAGGED(result);
		GROWABLE_ADD(result,string);

		finger = scan + 1;
	}

	FreeEnvironmentStrings(env);

	GROWABLE_TRIM(result);
	dpush(tag_object(result));
}

long exception_handler(PEXCEPTION_POINTERS pe)
{
	PEXCEPTION_RECORD e = (PEXCEPTION_RECORD)pe->ExceptionRecord;
	CONTEXT *c = (CONTEXT*)pe->ContextRecord;

	if(in_code_heap_p(c->Eip))
		signal_callstack_top = (void *)c->Esp;
	else
		signal_callstack_top = NULL;

	if(e->ExceptionCode == EXCEPTION_ACCESS_VIOLATION)
	{
		signal_fault_addr = e->ExceptionInformation[1];
		c->Eip = (CELL)memory_signal_handler_impl;
	}
	else if(e->ExceptionCode == EXCEPTION_FLT_DIVIDE_BY_ZERO
			|| e->ExceptionCode == EXCEPTION_INT_DIVIDE_BY_ZERO)
	{
		signal_number = ERROR_DIVIDE_BY_ZERO;
		c->Eip = (CELL)divide_by_zero_signal_handler_impl;
	}
	else
	{
		signal_number = 11;
		c->Eip = (CELL)misc_signal_handler_impl;
	}

	return EXCEPTION_CONTINUE_EXECUTION;
}

void c_to_factor_toplevel(CELL quot)
{
	AddVectoredExceptionHandler(0, (void*)exception_handler);
	c_to_factor(quot);
	RemoveVectoredExceptionHandler((void*)exception_handler);
}

void open_console(void)
{
}
