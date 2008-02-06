#include "master.h"

s64 current_millis(void)
{
	FILETIME t;
	GetSystemTimeAsFileTime(&t);
	return (((s64)t.dwLowDateTime | (s64)t.dwHighDateTime<<32)
		- EPOCH_OFFSET) / 10000;
}

DEFINE_PRIMITIVE(os_envs)
{
	GROWABLE_ARRAY(result);
	REGISTER_ROOT(result);

	TCHAR *env = GetEnvironmentStrings();
	TCHAR *finger = env;

	for(;;)
	{
		TCHAR *scan = finger;
		while(*scan != '\0')
			scan++;
		if(scan == finger)
			break;

		CELL string = tag_object(from_u16_string(finger));
		GROWABLE_ADD(result,string);

		finger = scan + 1;
	}

	FreeEnvironmentStrings(env);

	UNREGISTER_ROOT(result);
	GROWABLE_TRIM(result);
	dpush(result);
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
		c->EIP = (CELL)memory_signal_handler_impl;
	}
	else if(e->ExceptionCode == EXCEPTION_FLT_DIVIDE_BY_ZERO
			|| e->ExceptionCode == EXCEPTION_INT_DIVIDE_BY_ZERO)
	{
		signal_number = ERROR_DIVIDE_BY_ZERO;
		c->EIP = (CELL)divide_by_zero_signal_handler_impl;
	}
	else
	{
		signal_number = 11;
		c->EIP = (CELL)misc_signal_handler_impl;
	}

	return EXCEPTION_CONTINUE_EXECUTION;
}

void c_to_factor_toplevel(CELL quot)
{
	if(!AddVectoredExceptionHandler(0, (void*)exception_handler))
		fatal_error("AddVectoredExceptionHandler failed", 0);
	c_to_factor(quot);
	RemoveVectoredExceptionHandler((void*)exception_handler);
}

void open_console(void)
{
	/*
	// Do this: http://www.cygwin.com/ml/cygwin/2007-11/msg00432.html
	if(console_open)
		return;

	if(AttachConsole(ATTACH_PARENT_PROCESS) || AllocConsole())
	{
		console_open = true;
	}
	*/
}
