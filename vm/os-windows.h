#include <ctype.h>

#ifndef wcslen
  /* for cygwin */
  #include <wchar.h>
#endif

typedef wchar_t F_CHAR;

#define from_native_string from_u16_string
#define unbox_native_string unbox_u16_string
#define string_to_native_alien(string) string_to_u16_alien(string,true)

#define STRING_LITERAL(string) L##string

#define MAX_UNICODE_PATH 32768
#define DLLEXPORT __declspec(dllexport)
#define SSCANF swscanf
#define STRCMP wcscmp
#define STRNCMP wcsncmp
#define STRDUP _wcsdup
#define MIN(a,b) ((a)>(b)?(b):(a))
#define FSEEK fseek

#ifdef WIN64
	#define CELL_FORMAT "%Iu"
	#define CELL_HEX_FORMAT "%Ix"
	#define CELL_HEX_PAD_FORMAT "%016Ix"
	#define FIXNUM_FORMAT "%Id"
#else
	#define CELL_FORMAT "%lu"
	#define CELL_HEX_FORMAT "%lx"
	#define CELL_HEX_PAD_FORMAT "%08lx"
	#define FIXNUM_FORMAT "%ld"
#endif

#define OPEN_READ(path) _wfopen(path,L"rb")
#define OPEN_WRITE(path) _wfopen(path,L"wb")

#define print_native_string(string) wprintf(L"%s",string)

/* Difference between Jan 1 00:00:00 1601 and Jan 1 00:00:00 1970 */
#define EPOCH_OFFSET 0x019db1ded53e8000LL

void init_ffi(void);
void ffi_dlopen(F_DLL *dll);
void *ffi_dlsym(F_DLL *dll, F_SYMBOL *symbol);
void ffi_dlclose(F_DLL *dll);

void sleep_micros(u64 msec);

INLINE void init_signals(void) {}
INLINE void early_init(void) {}
const F_CHAR *vm_executable_path(void);
const F_CHAR *default_image_path(void);
long getpagesize (void);

s64 current_micros(void);

