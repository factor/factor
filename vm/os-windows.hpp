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

#ifdef _MSC_VER
	#define FTELL ftell
	#define FSEEK fseek
	#define SNPRINTF _snprintf
	#define SNWPRINTF _snwprintf
#else
	#define FTELL ftello64
	#define FSEEK fseeko64
	#define SNPRINTF snprintf
	#define SNWPRINTF snwprintf
#endif

#ifdef WIN64
	#define CELL_HEX_FORMAT "%Ix"
#else
	#define CELL_HEX_FORMAT "%lx"
#endif

#define OPEN_READ(path) _wfopen((path),L"rb")
#define OPEN_WRITE(path) _wfopen((path),L"wb")

/* Difference between Jan 1 00:00:00 1601 and Jan 1 00:00:00 1970 */
#define EPOCH_OFFSET 0x019db1ded53e8000LL

inline static void early_init() {}

u64 nano_count();
void sleep_nanos(u64 nsec);
long getpagesize();
void move_file(const vm_char *path1, const vm_char *path2);

}
