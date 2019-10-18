#include <dirent.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/time.h>
#include <dlfcn.h>

#define DLLEXPORT
#define SETJMP(jmpbuf) sigsetjmp(jmpbuf,1)
#define LONGJMP siglongjmp
#define JMP_BUF sigjmp_buf

void init_ffi(void);
void ffi_dlopen(DLL *dll, bool error);
void *ffi_dlsym(DLL *dll, F_STRING *symbol, bool error);
void ffi_dlclose(DLL *dll);

void unix_init_signals(void);
void signal_handler(int signal, siginfo_t* siginfo, void* uap);
void dump_stack_signal(int signal, siginfo_t* siginfo, void* uap);

void primitive_open_file(void);
void primitive_stat(void);
void primitive_read_dir(void);
void primitive_cwd(void);
void primitive_cd(void);

s64 current_millis(void);

void reset_stdio(void);
