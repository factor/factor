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

void c_to_factor_toplevel(cell quot);
FACTOR_STDCALL LONG exception_handler(PEXCEPTION_POINTERS pe);
void open_console();

// SSE traps raise these exception codes, which are defined in internal NT headers
// but not winbase.h
#define STATUS_FLOAT_MULTIPLE_FAULTS 0xC00002B4
#define STATUS_FLOAT_MULTIPLE_TRAPS  0xC00002B5

}
