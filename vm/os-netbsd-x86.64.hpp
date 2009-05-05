#include <ucontext.h>

namespace factor
{

#define ucontext_stack_pointer(uap) \
	((void *)(((ucontext_t *)(uap))->uc_mcontext.__gregs[_REG_URSP]))

}
