#include <ucontext.h>

namespace factor
{

inline static void *ucontext_stack_pointer(void *uap)
{
        ucontext_t *ucontext = (ucontext_t *)uap;
        return (void *)ucontext->uc_mcontext.gregs[15];
}

inline static unsigned int uap_fpu_status(void *uap)
{
        ucontext_t *ucontext = (ucontext_t *)uap;
        return ucontext->uc_mcontext.fpregs->swd
             | ucontext->uc_mcontext.fpregs->mxcsr;
}

inline static void uap_clear_fpu_status(void *uap)
{
        ucontext_t *ucontext = (ucontext_t *)uap;
        ucontext->uc_mcontext.fpregs->swd = 0;
        ucontext->uc_mcontext.fpregs->mxcsr &= 0xffffffc0;
}

#define UAP_PROGRAM_COUNTER(ucontext) \
	(((ucontext_t *)(ucontext))->uc_mcontext.gregs[16])

}
