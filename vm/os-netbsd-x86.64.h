#include <ucontext.h>

#define ucontext_stack_pointer(uap) \
	((void *)(((ucontext_t *)(uap))->uc_mcontext.__gregs[_REG_URSP]))
