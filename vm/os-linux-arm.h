#include <ucontext.h>
#include <asm/unistd.h>
#include <sys/syscall.h>

INLINE void *ucontext_stack_pointer(void *uap)
{
	ucontext_t *ucontext = (ucontext_t *)uap;
	return (void *)ucontext->uc_mcontext.arm_sp;
}

INLINE void flush_icache(CELL start, CELL len)
{
	syscall(__ARM_NR_cacheflush,start,start + len,0);
}
