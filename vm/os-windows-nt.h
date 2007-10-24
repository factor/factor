#undef _WIN32_WINNT
#define _WIN32_WINNT 0x0501  // For AddVectoredExceptionHandler

#ifndef UNICODE
#define UNICODE
#endif

#include <windows.h>

typedef char F_SYMBOL;

#define unbox_symbol_string unbox_char_string
#define from_symbol_string from_char_string

#define FACTOR_OS_STRING "windows"
#define FACTOR_DLL L"factor-nt.dll"
#define FACTOR_DLL_NAME "factor-nt.dll"

void c_to_factor_toplevel(CELL quot);

void memory_signal_handler_impl(void);
void divide_by_zero_signal_handler_impl(void);
void misc_signal_handler_impl(void);

long exception_handler(PEXCEPTION_POINTERS pe);
