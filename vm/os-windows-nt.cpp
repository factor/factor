#include "master.hpp"

namespace factor
{

THREADHANDLE start_thread(void *(*start_routine)(void *), void *args)
{
	return (void *)CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)start_routine, args, 0, 0);
}

u64 system_micros()
{
	FILETIME t;
	GetSystemTimeAsFileTime(&t);
	return (((u64)t.dwLowDateTime | (u64)t.dwHighDateTime<<32)
		- EPOCH_OFFSET) / 10;
}

u64 nano_count()
{
	LARGE_INTEGER count;
	LARGE_INTEGER frequency;
	static u32 hi = 0;
	static u32 lo = 0;
	BOOL ret;
	ret = QueryPerformanceCounter(&count);
	if(ret == 0)
		fatal_error("QueryPerformanceCounter", 0);
	ret = QueryPerformanceFrequency(&frequency);
	if(ret == 0)
		fatal_error("QueryPerformanceFrequency", 0);

#ifdef FACTOR_64
	hi = count.HighPart;
#else
	/* On VirtualBox, QueryPerformanceCounter does not increment
	the high part every time the low part overflows.  Workaround. */
	if(lo > count.LowPart)
		hi++;
#endif
	lo = count.LowPart;

	return (u64)((((u64)hi << 32) | (u64)lo)*(1000000000.0/frequency.QuadPart));
}

void sleep_nanos(u64 nsec)
{
	Sleep((DWORD)(nsec/1000000));
}

LONG factor_vm::exception_handler(PEXCEPTION_RECORD e, void *frame, PCONTEXT c, void *dispatch)
{
	c->ESP = (cell)fix_callstack_top((stack_frame *)c->ESP);
	signal_callstack_top = (stack_frame *)c->ESP;

	switch (e->ExceptionCode)
	{
	case EXCEPTION_ACCESS_VIOLATION:
		signal_fault_addr = e->ExceptionInformation[1];
		c->EIP = (cell)factor::memory_signal_handler_impl;
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
#ifdef FACTOR_64
		signal_fpu_status = fpu_status(MXCSR(c));
#else
		signal_fpu_status = fpu_status(X87SW(c) | MXCSR(c));
		X87SW(c) = 0;
#endif
		MXCSR(c) &= 0xffffffc0;
		c->EIP = (cell)factor::fp_signal_handler_impl;
		break;
	default:
		signal_number = e->ExceptionCode;
		c->EIP = (cell)factor::misc_signal_handler_impl;
		break;
	}

	return ExceptionContinueExecution;
}

VM_C_API LONG exception_handler(PEXCEPTION_RECORD e, void *frame, PCONTEXT c, void *dispatch)
{
	return current_vm()->exception_handler(e,frame,c,dispatch);
}

void factor_vm::c_to_factor_toplevel(cell quot)
{
	c_to_factor(quot);
}

void factor_vm::open_console()
{
}

}
