#include <dirent.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/time.h>
#include <dlfcn.h>
#include <signal.h>

typedef char F_CHAR;
typedef char F_SYMBOL;

#define from_native_string from_char_string
#define unbox_native_string unbox_char_string
#define string_to_native_alien(string) string_to_char_alien(string,true)
#define unbox_symbol_string unbox_char_string

#define STR_FORMAT(string) string

#define SSCANF sscanf
#define STRCMP strcmp
#define STRNCMP strncmp
#define STRDUP strdup

#define OPEN_READ(path) fopen(path,"rb")
#define OPEN_WRITE(path) fopen(path,"wb")
#define FPRINTF(stream,format,arg) fprintf(stream,format,arg)

void init_ffi(void);
void ffi_dlopen(F_DLL *dll, bool error);
void *ffi_dlsym(F_DLL *dll, F_SYMBOL *symbol);
void ffi_dlclose(F_DLL *dll);

void unix_init_signals(void);
void signal_handler(int signal, siginfo_t* siginfo, void* uap);
void dump_stack_signal(int signal, siginfo_t* siginfo, void* uap);

s64 current_millis(void);
void sleep_millis(CELL msec);

void reset_stdio(void);
