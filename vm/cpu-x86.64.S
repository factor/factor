#include "asm.h"

#define ARG0 %rdi
#define ARG1 %rsi
#define XT_REG %rcx
#define STACK_REG %rsp
#define DS_REG %r14

#define CELL_SIZE 8

#define PUSH_NONVOLATILE \
	push %rbx ; \
	push %rbp ; \
	push %r12 ; \
	push %r13 ;

#define POP_NONVOLATILE \
	pop %r13 ; \
	pop %r12 ; \
	pop %rbp ; \
	pop %rbx

#define QUOT_XT_OFFSET 13
#define PROFILING_OFFSET 53
#define WORD_DEF_OFFSET 29
#define WORD_XT_OFFSET 61

/* We pass a function pointer to memcpy to work around a Mac OS X
ABI limitation which would otherwise require us to do a bizzaro PC-relative
trampoline to retrieve the function address */
DEF(void,set_callstack,(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy)):
	sub %rdx,%rdi                      /* compute new stack pointer */
	mov %rdi,%rsp
	call *%rcx                         /* call memcpy */
	ret                                /* return _with new stack_ */

#include "cpu-x86.S"
