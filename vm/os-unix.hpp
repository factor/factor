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

#define FTELL ftello
#define FSEEK fseeko

#define OPEN_READ(path) fopen(path, "rb")
#define OPEN_WRITE(path) fopen(path, "wb")

#ifdef _GNU_SOURCE
extern "C" {
  extern int __xpg_strerror_r (int __errnum, char *__buf, size_t __buflen);
}
#define strerror_r __xpg_strerror_r
#endif

#define THREADSAFE_STRERROR(errnum, buf, buflen) strerror_r(errnum, buf, buflen)

#define print_native_string(string) print_string(string)

typedef pthread_t THREADHANDLE;

THREADHANDLE start_thread(void* (*start_routine)(void*), void* args);
inline static THREADHANDLE thread_id() { return pthread_self(); }

uint64_t nano_count();
void sleep_nanos(uint64_t nsec);

void* native_dlopen(const char* path);
void* native_dlsym(void* handle, const char* symbol);
void native_dlclose(void* handle);

void check_ENOMEM(const char* msg);

[[noreturn]] static inline void breakpoint() { __builtin_trap(); }

#define AS_UTF8(ptr) ptr

// Console I/O thread variables
extern "C" {
extern int stdin_read;
extern int stdin_write;
extern int control_read;
extern int control_write;
extern int size_read;
extern int size_write;
extern bool stdin_thread_initialized_p;
extern THREADHANDLE stdin_thread;
extern pthread_mutex_t stdin_mutex;
}

}
