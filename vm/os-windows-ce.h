#ifndef UNICODE
#define UNICODE
#endif

#include <windows.h>
#include <ctype.h>

typedef wchar_t F_SYMBOL;

#define unbox_symbol_string unbox_u16_string
#define from_symbol_string from_u16_string

#define FACTOR_OS_STRING "wince"
#define FACTOR_DLL L"factor-ce.dll"
#define FACTOR_DLL_NAME "factor-ce.dll"

int errno;
char *strerror(int err);
void flush_icache(CELL start, CELL end);
char *getenv(char *name);

#define snprintf _snprintf
#define snwprintf _snwprintf

s64 current_millis(void);
void c_to_factor_toplevel(CELL quot);
