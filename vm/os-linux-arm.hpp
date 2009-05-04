#include <ucontext.h>
#include <asm/unistd.h>
#include <sys/syscall.h>

namespace factor
{

inline static void *ucontext_stack_pointer(void *uap)
{
	ucontext_t *ucontext = (ucontext_t *)uap;
	return (void *)ucontext->uc_mcontext.arm_sp;
}

#define UAP_PROGRAM_COUNTER(ucontext) \
	(((ucontext_t *)(ucontext))->uc_mcontext.arm_pc)

void flush_icache(cell start, cell len);

}
