#undef _WIN32_WINNT
#define _WIN32_WINNT 0x0501  // For AddVectoredExceptionHandler

#ifndef UNICODE
#define UNICODE
#endif

#include <windows.h>
#include <shellapi.h>

namespace factor
{

typedef char symbol_char;

#define FACTOR_OS_STRING "winnt"
#define FACTOR_DLL L"factor.dll"
#define FACTOR_DLL_NAME "factor.dll"

#define FACTOR_STDCALL __attribute__((stdcall))

FACTOR_STDCALL LONG exception_handler(PEXCEPTION_POINTERS pe);

// SSE traps raise these exception codes, which are defined in internal NT headers
// but not winbase.h
#define STATUS_FLOAT_MULTIPLE_FAULTS 0xC00002B4
#define STATUS_FLOAT_MULTIPLE_TRAPS  0xC00002B5

typedef HANDLE THREADHANDLE;

THREADHANDLE start_thread(void *(*start_routine)(void *),void *args);

void init_platform_globals();
struct factorvm;
void register_vm_with_thread(factorvm *vm);
factorvm *tls_vm();

}
