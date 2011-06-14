#include <ucontext.h>

#define UAP_PROGRAM_COUNTER(uap) _UC_MACHINE_PC((ucontext_t *)uap)

#define UAP_STACK_POINTER_TYPE __greg_t

#define UAP_SET_TOC_POINTER(uap, ptr) (void)0
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
