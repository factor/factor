#include <ucontext.h>

#define FRAME_RETURN_ADDRESS(frame) *((XT *)(frame_successor(frame) + 1) + 1)

INLINE void *ucontext_stack_pointer(void *uap)
{
        ucontext_t *ucontext = (ucontext_t *)uap;
        return (void *)ucontext->uc_mcontext.uc_regs->gregs[PT_R1];
}

#define UAP_PROGRAM_COUNTER(ucontext) \
	(((ucontext_t *)(ucontext))->uc_mcontext.uc_regs->gregs[PT_NIP])
