#include <unistd.h>
#include <sys/param.h>
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
#define CELL_FORMAT "%lu"
#define CELL_HEX_FORMAT "%lx"

#ifdef FACTOR_64
	#define CELL_HEX_PAD_FORMAT "%016lx"
#else
	#define CELL_HEX_PAD_FORMAT "%08lx"
#endif

#define FIXNUM_FORMAT "%ld"

#define OPEN_READ(path) fopen(path,"rb")
#define OPEN_WRITE(path) fopen(path,"wb")

#define print_native_string(string) print_string(string)

typedef pthread_t THREADHANDLE;

THREADHANDLE start_thread(void *(*start_routine)(void *),void *args);
pthread_t thread_id();

void unix_init_signals();
void signal_handler(int signal, siginfo_t* siginfo, void* uap);
void dump_stack_signal(int signal, siginfo_t* siginfo, void* uap);

s64 current_micros();
void sleep_micros(cell usec);

void init_platform_globals();
struct factorvm;
void register_vm_with_thread(factorvm *vm);
factorvm *tls_vm();
void open_console();
}
