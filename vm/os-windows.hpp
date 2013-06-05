#include <ctype.h>

#ifndef wcslen
/* for cygwin */
#include <wchar.h>
#endif

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

/* Difference between Jan 1 00:00:00 1601 and Jan 1 00:00:00 1970 */
#define EPOCH_OFFSET 0x019db1ded53e8000LL

namespace factor {

typedef wchar_t vm_char;
typedef char symbol_char;
typedef HANDLE THREADHANDLE;

#define STRING_LITERAL(string) L##string

#define MAX_UNICODE_PATH 32768
#define VM_C_API extern "C" __declspec(dllexport)
#define SSCANF swscanf
#define STRCMP wcscmp
#define STRNCMP wcsncmp
#define STRDUP _wcsdup

#ifdef _MSC_VER
#define FTELL ftell
#define FSEEK fseek
#define SNPRINTF _snprintf
#else
#define FTELL ftello64
#define FSEEK fseeko64
#define SNPRINTF snprintf
#endif

#define FACTOR_OS_STRING "windows"

#define FACTOR_DLL NULL

// SSE traps raise these exception codes, which are defined in internal NT
// headers
// but not winbase.h
#ifndef STATUS_FLOAT_MULTIPLE_FAULTS
#define STATUS_FLOAT_MULTIPLE_FAULTS 0xC00002B4
#endif

#ifndef STATUS_FLOAT_MULTIPLE_TRAPS
#define STATUS_FLOAT_MULTIPLE_TRAPS 0xC00002B5
#endif

#define OPEN_READ(path) _wfopen((path), L"rb")
#define OPEN_WRITE(path) _wfopen((path), L"wb")

inline static void early_init() {}
uint64_t nano_count();
void sleep_nanos(uint64_t nsec);
long getpagesize();
void move_file(const vm_char* path1, const vm_char* path2);
VM_C_API LONG exception_handler(PEXCEPTION_RECORD e, void* frame, PCONTEXT c,
                                void* dispatch);
THREADHANDLE start_thread(void* (*start_routine)(void*), void* args);

inline static THREADHANDLE thread_id() {
  DWORD id = GetCurrentThreadId();
  HANDLE threadHandle = OpenThread(
      THREAD_GET_CONTEXT | THREAD_SET_CONTEXT | THREAD_SUSPEND_RESUME, FALSE,
      id);
  FACTOR_ASSERT(threadHandle != NULL);
  return threadHandle;
}

inline static void breakpoint() { DebugBreak(); }

#define CODE_TO_FUNCTION_POINTER(code) (void) 0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void) 0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}
