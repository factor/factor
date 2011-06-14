#include <ucontext.h>

namespace factor
{

#define UAP_STACK_POINTER(ucontext) (((ucontext_t *)ucontext)->uc_mcontext.gregs[RSP])
#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t *)ucontext)->uc_mcontext.gregs[RIP])

#define UAP_SET_TOC_POINTER(uap, ptr) (void)0
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
}
