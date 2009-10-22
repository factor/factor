#include <ucontext.h>

namespace factor
{

#define FRAME_RETURN_ADDRESS(frame,vm) *((void **)(vm->frame_successor(frame) + 1) + 1)
#define UAP_STACK_POINTER(ucontext) ((ucontext_t *)ucontext)->uc_mcontext.uc_regs->gregs[PT_R1]
#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t *)ucontext)->uc_mcontext.uc_regs->gregs[PT_NIP])

}
