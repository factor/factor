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

FACTOR_STDCALL LONG exception_handler(PEXCEPTION_POINTERS pe)
{
	PEXCEPTION_RECORD e = (PEXCEPTION_RECORD)pe->ExceptionRecord;
	CONTEXT *c = (CONTEXT*)pe->ContextRecord;

	if(in_code_heap_p(c->EIP))
		signal_callstack_top = (stack_frame *)c->ESP;
	else
		signal_callstack_top = NULL;

	switch (e->ExceptionCode)
	{
	case EXCEPTION_ACCESS_VIOLATION:
		signal_fault_addr = e->ExceptionInformation[1];
		c->EIP = (cell)memory_signal_handler_impl;
	break;

	case STATUS_FLOAT_DENORMAL_OPERAND:
	case STATUS_FLOAT_DIVIDE_BY_ZERO:
	case STATUS_FLOAT_INEXACT_RESULT:
	case STATUS_FLOAT_INVALID_OPERATION:
	case STATUS_FLOAT_OVERFLOW:
	case STATUS_FLOAT_STACK_CHECK:
	case STATUS_FLOAT_UNDERFLOW:
	case STATUS_FLOAT_MULTIPLE_FAULTS:
	case STATUS_FLOAT_MULTIPLE_TRAPS:
		signal_fpu_status = fpu_status(X87SW(c) | MXCSR(c));
		X87SW(c) = 0;
		MXCSR(c) &= 0xffffffc0;
		c->EIP = (cell)fp_signal_handler_impl;
		break;
	case 0x40010006:
		/* If the Widcomm bluetooth stack is installed, the BTTray.exe
		process injects code into running programs. For some reason this
		results in random SEH exceptions with this (undocumented)
		exception code being raised. The workaround seems to be ignoring
		this altogether, since that is what happens if SEH is not
		enabled. Don't really have any idea what this exception means. */
		break;
	default:
		signal_number = e->ExceptionCode;
		c->EIP = (cell)misc_signal_handler_impl;
		break;
	}
	return EXCEPTION_CONTINUE_EXECUTION;
}

void c_to_factor_toplevel(cell quot)
{
	if(!AddVectoredExceptionHandler(0, (PVECTORED_EXCEPTION_HANDLER)exception_handler))
		fatal_error("AddVectoredExceptionHandler failed", 0);
	c_to_factor(quot);
	RemoveVectoredExceptionHandler((void *)exception_handler);
}

void open_console()
{
}

}
