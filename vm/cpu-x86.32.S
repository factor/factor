#include "asm.h"

/* Note that primitive word definitions are compiled with
__attribute__((regparm 2), so the pointer to the word object is passed in EAX,
and the callstack top is passed in EDX */

#define ARG0 %eax
#define ARG1 %edx
#define XT_REG %ecx
#define STACK_REG %esp
#define DS_REG %esi

#define CELL_SIZE 4

#define PUSH_NONVOLATILE \
	push %ebx ; \
	push %ebp

#define POP_NONVOLATILE \
	pop %ebp ; \
	pop %ebx

#define QUOT_XT_OFFSET 9
#define PROFILING_OFFSET 25
#define WORD_DEF_OFFSET 13
#define WORD_XT_OFFSET 29

/* We pass a function pointer to memcpy to work around a Mac OS X
ABI limitation which would otherwise require us to do a bizzaro PC-relative
trampoline to retrieve the function address */
DEF(void,set_callstack,(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy)):
	mov 4(%esp),%ebp                   /* to */
	mov 8(%esp),%edx                   /* from */
	mov 12(%esp),%ecx                  /* length */
	mov 16(%esp),%eax                  /* memcpy */
	sub %ecx,%ebp                      /* compute new stack pointer */
	mov %ebp,%esp
	push %ecx                          /* pass length */
	push %edx                          /* pass src */
	push %ebp                          /* pass dst */
	call *%eax                         /* call memcpy */
	add $12,%esp                       /* pop args from the stack */
	ret                                /* return _with new stack_ */

#include "cpu-x86.S"
