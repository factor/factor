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
#include <sched.h>

#include "atomic-gcc.hpp"

namespace factor {

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

#define OPEN_READ(path) fopen(path, "rb")
#define OPEN_WRITE(path) fopen(path, "wb")
#define THREADSAFE_STRERROR(errnum, buf, buflen) strerror_r(errnum, buf, buflen)

#define print_native_string(string) print_string(string)

typedef pthread_t THREADHANDLE;

THREADHANDLE start_thread(void* (*start_routine)(void*), void* args);
inline static THREADHANDLE thread_id() { return pthread_self(); }

uint64_t nano_count();
void sleep_nanos(uint64_t nsec);

void move_file(const vm_char* path1, const vm_char* path2);

static inline void breakpoint() { __builtin_trap(); }

}
