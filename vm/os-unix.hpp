#include <dirent.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/time.h>
#include <dlfcn.h>
#include <signal.h>
#include <pthread.h>

namespace factor
{

typedef char vm_char;
typedef char symbol_char;

#define STRING_LITERAL(string) string

#define SSCANF sscanf
#define STRCMP strcmp
#define STRNCMP strncmp
#define STRDUP strdup

#define FSEEK fseeko

#define FIXNUM_FORMAT "%ld"
#define cell_FORMAT "%lu"
#define cell_HEX_FORMAT "%lx"

#ifdef FACTOR_64
	#define cell_HEX_PAD_FORMAT "%016lx"
#else
	#define cell_HEX_PAD_FORMAT "%08lx"
#endif

#define FIXNUM_FORMAT "%ld"

#define OPEN_READ(path) fopen(path,"rb")
#define OPEN_WRITE(path) fopen(path,"wb")

#define print_native_string(string) print_string(string)

void start_thread(void *(*start_routine)(void *));

void init_ffi();
void ffi_dlopen(dll *dll);
void *ffi_dlsym(dll *dll, symbol_char *symbol);
void ffi_dlclose(dll *dll);

void unix_init_signals();
void signal_handler(int signal, siginfo_t* siginfo, void* uap);
void dump_stack_signal(int signal, siginfo_t* siginfo, void* uap);

s64 current_micros();
void sleep_micros(cell usec);

void open_console();

}
