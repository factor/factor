#include <ucontext.h>

#define UAP_PROGRAM_COUNTER(uap)    _UC_MACHINE_PC((ucontext_t *)uap)

#define UNKNOWN_TYPE_P(file) ((file)->d_type == DT_UNKNOWN)
#define DIRECTORY_P(file) ((file)->d_type == DT_DIR)

extern char **environ;
