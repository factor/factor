#include <ucontext.h>
#include <asm/unistd.h>
#include <sys/syscall.h>

namespace factor
{

void flush_icache(cell start, cell len);

#define UAP_STACK_POINTER(ucontext) (((ucontext_t *)ucontext)->uc_mcontext.arm_sp)
#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t *)ucontext)->uc_mcontext.arm_pc)

}
