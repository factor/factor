#ifndef UNICODE
#define UNICODE
#endif

#include <ctype.h>

typedef wchar_t F_SYMBOL;

#define unbox_symbol_string unbox_u16_string
#define from_symbol_string from_u16_string

#define FACTOR_OS_STRING "wince"

int errno;
char *strerror(int err);
void flush_icache();
char *getenv(char *name);

#define snprintf _snprintf
#define snwprintf _snwprintf

s64 current_millis(void);
void primitive_cwd(void);
void primitive_cd(void);

