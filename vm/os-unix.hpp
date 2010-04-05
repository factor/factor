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
#define SNPRINTF snprintf

#define FTELL ftello
#define FSEEK fseeko

#define CELL_HEX_FORMAT "%lx"

#define OPEN_READ(path) fopen(path,"rb")
#define OPEN_WRITE(path) fopen(path,"wb")

#define print_native_string(string) print_string(string)

typedef pthread_t THREADHANDLE;

THREADHANDLE start_thread(void *(*start_routine)(void *),void *args);
inline static THREADHANDLE thread_id() { return pthread_self(); }

void signal_handler(int signal, siginfo_t* siginfo, void* uap);
void dump_stack_signal(int signal, siginfo_t* siginfo, void* uap);

u64 system_micros();
u64 nano_count();
void sleep_nanos(u64 nsec);
void open_console();

void move_file(const vm_char *path1, const vm_char *path2);

}
