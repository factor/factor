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

#define FACTOR_DLL NULL

LONG exception_handler(PEXCEPTION_RECORD e, void *frame, PCONTEXT c, void *dispatch);

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

}
