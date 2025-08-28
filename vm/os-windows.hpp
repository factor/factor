#include <ctype.h>

#ifndef wcslen
// for cygwin
#include <wchar.h>
#endif

#ifndef UNICODE
#define UNICODE
#endif

#include <windows.h>
#include <shellapi.h>

#ifdef _MSC_VER
#undef min
#undef max
#endif

// Difference between Jan 1 00:00:00 1601 and Jan 1 00:00:00 1970
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
#else
#define FTELL ftello64
#define FSEEK fseeko64
#endif

#define FACTOR_OS_STRING "windows"

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
#define THREADSAFE_STRERROR(errnum, buf, buflen) strerror_s(buf, buflen, errnum)

inline static void early_init() {}
[[nodiscard]] uint64_t nano_count();
void sleep_nanos(uint64_t nsec);

[[nodiscard]] void* native_dlopen(const char* path);
[[nodiscard]] void* native_dlsym(void* handle, const char* symbol);
void native_dlclose(void* handle);

[[nodiscard]] long getpagesize();
VM_C_API LONG exception_handler(PEXCEPTION_RECORD e, void* frame, PCONTEXT c,
                                void* dispatch);
[[nodiscard]] THREADHANDLE start_thread(void* (*start_routine)(void*), void* args);

inline static THREADHANDLE thread_id() {
  DWORD id = GetCurrentThreadId();
  HANDLE threadHandle = OpenThread(
      THREAD_GET_CONTEXT | THREAD_SET_CONTEXT | THREAD_SUSPEND_RESUME, FALSE,
      id);
  FACTOR_ASSERT(threadHandle != NULL);
  return threadHandle;
}

inline static void breakpoint() { DebugBreak(); }

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

extern HANDLE boot_thread;

inline static std::string to_utf8(const wchar_t* buffer, int len) {
  int nChars = ::WideCharToMultiByte(
    CP_UTF8,
    0,
    buffer,
    len,
    NULL,
    0,
    NULL,
    NULL);
  if (nChars == 0) return "";

  std::string newbuffer;
  newbuffer.resize(nChars) ;
  ::WideCharToMultiByte(
    CP_UTF8,
    0,
    buffer,
    len,
    const_cast<char*>(newbuffer.c_str()),
    nChars,
    NULL,
    NULL);
  return newbuffer;
}

inline static std::string to_utf8(const std::wstring& str) {
  return to_utf8(str.c_str(), (int)str.size());
}

#define AS_UTF8(ptr) to_utf8(ptr)

#define ZSTD_LIB "zstd-1.dll"

}
