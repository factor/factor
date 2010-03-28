#undef _WIN32_WINNT
#define _WIN32_WINNT 0x0501  // For AddVectoredExceptionHandler

#ifndef UNICODE
#define UNICODE
#endif

#include <windows.h>
#include <shellapi.h>

#ifdef _MSC_VER
	#undef min
	#undef max
#endif

namespace factor
{

typedef char symbol_char;

#define FACTOR_OS_STRING "winnt"

#define FACTOR_DLL L"factor.dll"

#ifdef _MSC_VER
	#define FACTOR_STDCALL(return_type) return_type __stdcall
#else
	#define FACTOR_STDCALL(return_type) __attribute__((stdcall)) return_type
#endif

FACTOR_STDCALL(LONG) exception_handler(PEXCEPTION_POINTERS pe);

// SSE traps raise these exception codes, which are defined in internal NT headers
// but not winbase.h
#ifndef STATUS_FLOAT_MULTIPLE_FAULTS
#define STATUS_FLOAT_MULTIPLE_FAULTS 0xC00002B4
#endif

#ifndef STATUS_FLOAT_MULTIPLE_TRAPS
#define STATUS_FLOAT_MULTIPLE_TRAPS  0xC00002B5
#endif

typedef HANDLE THREADHANDLE;

THREADHANDLE start_thread(void *(*start_routine)(void *),void *args);
inline static THREADHANDLE thread_id() { return GetCurrentThread(); }

void init_platform_globals();
void register_vm_with_thread(factor_vm *vm);
factor_vm *current_vm();

}
