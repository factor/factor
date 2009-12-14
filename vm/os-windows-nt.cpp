#include "master.hpp"

namespace factor
{

THREADHANDLE start_thread(void *(*start_routine)(void *), void *args)
{
	return (void *)CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)start_routine, args, 0, 0);
}

DWORD dwTlsIndex; 

void init_platform_globals()
{
	if ((dwTlsIndex = TlsAlloc()) == TLS_OUT_OF_INDEXES)
		fatal_error("TlsAlloc failed - out of indexes",0);
}

void register_vm_with_thread(factor_vm *vm)
{
	if (! TlsSetValue(dwTlsIndex, vm))
		fatal_error("TlsSetValue failed",0);
}

factor_vm *tls_vm()
{
	factor_vm *vm = (factor_vm*)TlsGetValue(dwTlsIndex);
	assert(vm != NULL);
	return vm;
}

u64 system_micros()
{
	FILETIME t;
	GetSystemTimeAsFileTime(&t);
	return (((u64)t.dwLowDateTime | (u64)t.dwHighDateTime<<32)
		- EPOCH_OFFSET) / 10;
}

/* On VirtualBox, QueryPerformanceCounter does not increment
the high part every time the low part overflows.  Workaround. */
u64 nano_count()
{
	LARGE_INTEGER count;
	LARGE_INTEGER frequency;
	static u32 hi_correction = 0;
	static u32 hi = 0xffffffff;
	static u32 lo = 0xffffffff;
	BOOL ret;
	ret = QueryPerformanceCounter(&count);
	if(ret == 0)
		fatal_error("QueryPerformanceCounter", 0);
	ret = QueryPerformanceFrequency(&frequency);
	if(ret == 0)
		fatal_error("QueryPerformanceFrequency", 0);

	if((u32)count.LowPart < lo && (u32)count.HighPart == hi)
		hi_correction++;

	hi = count.HighPart;
	lo = count.LowPart;
	count.HighPart += hi_correction;

	return count.QuadPart*(1000000000/frequency.QuadPart);
}

void sleep_nanos(u64 nsec)
{
	Sleep((DWORD)(nsec/1000000));
}

LONG factor_vm::exception_handler(PEXCEPTION_POINTERS pe)
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
		signal_fpu_status = fpu_status(X87SW(c) | MXCSR(c));
		X87SW(c) = 0;
		MXCSR(c) &= 0xffffffc0;
		c->EIP = (cell)factor::fp_signal_handler_impl;
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
		c->EIP = (cell)factor::misc_signal_handler_impl;
		break;
	}
	return EXCEPTION_CONTINUE_EXECUTION;
}

FACTOR_STDCALL LONG exception_handler(PEXCEPTION_POINTERS pe)
{
	return tls_vm()->exception_handler(pe);
}

bool handler_added = 0;

void factor_vm::c_to_factor_toplevel(cell quot)
{
	if(!handler_added){
		if(!AddVectoredExceptionHandler(0, (PVECTORED_EXCEPTION_HANDLER)factor::exception_handler))
			fatal_error("AddVectoredExceptionHandler failed", 0);
		handler_added = 1;
	}
	c_to_factor(quot,this);
 	RemoveVectoredExceptionHandler((void *)factor::exception_handler);
}

void factor_vm::open_console()
{
}

}
