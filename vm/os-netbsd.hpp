#include <ucontext.h>

#define UAP_PROGRAM_COUNTER(uap) _UC_MACHINE_PC((ucontext_t *)uap)

#define UAP_STACK_POINTER_TYPE __greg_t
