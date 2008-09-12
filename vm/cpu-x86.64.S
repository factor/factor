#include "asm.h"

#define ARG0 %rdi
#define ARG1 %rsi
#define STACK_REG %rsp
#define DS_REG %r14
#define RETURN_REG %rax

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

#define QUOT_XT_OFFSET 21

/* We pass a function pointer to memcpy to work around a Mac OS X
ABI limitation which would otherwise require us to do a bizzaro PC-relative
trampoline to retrieve the function address */
DEF(void,set_callstack,(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy)):
	sub %rdx,%rdi                      /* compute new stack pointer */
	mov %rdi,%rsp
	call *%rcx                         /* call memcpy */
	ret                                /* return _with new stack_ */

#include "cpu-x86.S"
