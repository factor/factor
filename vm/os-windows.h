#include <windows.h>
#include <ctype.h>

#define FACTOR_OS_STRING "windows"

#define DLLEXPORT __declspec(dllexport)
#define SETJMP setjmp
#define LONGJMP longjmp
#define JMP_BUF jmp_buf

/* Difference between Jan 1 00:00:00 1601 and Jan 1 00:00:00 1970 */
#define EPOCH_OFFSET 0x019db1ded53e8000LL

char *buffer_to_c_string(char *buffer);
F_STRING *get_error_message(void);
DLLEXPORT char *error_message(DWORD id);

INLINE void init_ffi(void) {}
void ffi_dlopen(F_DLL *dll, bool error);
void *ffi_dlsym(F_DLL *dll, char *symbol, bool error);
void ffi_dlclose(F_DLL *dll);

void primitive_open_file(void);
void primitive_stat(void);
void primitive_read_dir(void);
void primitive_cwd(void);
void primitive_cd(void);

INLINE void init_signals(void) {}
INLINE void early_init(void) {}
const char *default_image_path(void);
long getpagesize (void);

s64 current_millis(void);

INLINE void reset_stdio(void) {}
