#include <ucontext.h>

namespace factor
{

#define UAP_STACK_POINTER(ucontext) (((ucontext_t *)ucontext)->uc_mcontext.gregs[ESP])
#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t *)ucontext)->uc_mcontext.gregs[EIP])

}
