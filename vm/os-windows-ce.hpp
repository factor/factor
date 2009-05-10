#ifndef UNICODE
#define UNICODE
#endif

#include <windows.h>
#include <ctype.h>

namespace factor
{

typedef wchar_t symbol_char;

#define FACTOR_OS_STRING "wince"
#define FACTOR_DLL L"factor-ce.dll"
#define FACTOR_DLL_NAME "factor-ce.dll"

int errno;
char *strerror(int err);
void flush_icache(cell start, cell end);
char *getenv(char *name);

#define snprintf _snprintf
#define snwprintf _snwprintf

s64 current_micros();
void c_to_factor_toplevel(cell quot);
void open_console();

}
