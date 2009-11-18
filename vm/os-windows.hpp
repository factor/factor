#include <ctype.h>

#ifndef wcslen
  /* for cygwin */
  #include <wchar.h>
#endif

namespace factor
{

typedef wchar_t vm_char;

#define STRING_LITERAL(string) L##string

#define MAX_UNICODE_PATH 32768
#define VM_C_API extern "C" __declspec(dllexport)
#define SSCANF swscanf
#define STRCMP wcscmp
#define STRNCMP wcsncmp
#define STRDUP _wcsdup
#define MIN(a,b) ((a)>(b)?(b):(a))
#define FTELL ftello64
#define FSEEK fseeko64

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

/* Difference between Jan 1 00:00:00 1601 and Jan 1 00:00:00 1970 */
#define EPOCH_OFFSET 0x019db1ded53e8000LL

inline static void init_signals() {}
inline static void early_init() {}

u64 system_micros();
u64 nano_count();
long getpagesize();

}
