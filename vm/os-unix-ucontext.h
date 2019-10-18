#include <ucontext.h>

INLINE void *default_stack_pointer(void *uap)
{
	ucontext_t *ucontext = (ucontext_t *)uap;
	return ucontext->uc_stack.ss_sp;
}

#define ucontext_stack_pointer default_stack_pointer
