#include "asm.h"

/* Note that primitive word definitions are compiled with
__attribute__((regparm 2), so the pointer to the word object is passed in EAX,
and the callstack top is passed in EDX */

#define ARG0 %eax
#define ARG1 %edx
#define STACK_REG %esp
#define DS_REG %esi
#define RETURN_REG %eax

#define NV_TEMP_REG %ebx

#define ARITH_TEMP_1 %ebp
#define ARITH_TEMP_2 %ebx
#define DIV_RESULT %eax

#define CELL_SIZE 4
#define STACK_PADDING 12

#define PUSH_NONVOLATILE \
	push %ebx ; \
	push %ebp ; \
	push %ebp

#define POP_NONVOLATILE \
	pop %ebp ; \
	pop %ebp ; \
	pop %ebx

#define QUOT_XT_OFFSET 16
#define WORD_XT_OFFSET 30

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

/* cpu.x86.32 calls this */
DEF(bool,check_sse2,(void)):
	push %ebx
	mov $1,%eax
	cpuid
	shr $26,%edx
	and $1,%edx
	pop %ebx
	mov %edx,%eax
	ret

DEF(F_FASTCALL void,primitive_inline_cache_miss,(void)):
	mov (%esp),%eax
	sub $8,%esp
	push %eax
	call MANGLE(inline_cache_miss)
	add $12,%esp
	jmp *%eax

#include "cpu-x86.S"

#ifdef WINDOWS
	.section .drectve
	.ascii " -export:check_sse2"
#endif
