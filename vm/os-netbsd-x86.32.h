#include <ucontext.h>

#define ucontext_stack_pointer(uap) ((void *)_UC_MACHINE_SP((ucontext_t *)uap))
