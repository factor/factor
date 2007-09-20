#include <ucontext.h>

INLINE void *ucontext_stack_pointer(void *uap)
{
	ucontext_t *ucontext = (ucontext_t *)uap;
	return ucontext->uc_stack.ss_sp;
}
