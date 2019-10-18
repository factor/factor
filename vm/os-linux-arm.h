#include <asm/unistd.h>
#include <sys/syscall.h>

INLINE void *arm_stack_pointer(void *uap)
{
	ucontext_t *ucontext = (ucontext_t *)uap;
	return (void *)ucontext->uc_mcontext.arm_sp;
}

#undef ucontext_stack_pointer
#define ucontext_stack_pointer arm_stack_pointer

INLINE void flush_icache(CELL start, CELL len)
{
	syscall(__ARM_NR_cacheflush,start,start + len,0);
}
