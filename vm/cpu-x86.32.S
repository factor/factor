#include "asm.h"

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

#define QUOT_XT_OFFSET 12

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

DEF(long long,read_timestamp_counter,(void)):
	rdtsc
	ret

DEF(void,primitive_inline_cache_miss,(void)):
	mov (%esp),%ebx
DEF(void,primitive_inline_cache_miss_tail,(void)):
	sub $8,%esp
	push %ebx
	call MANGLE(inline_cache_miss)
	add $12,%esp
	jmp *%eax

DEF(void,get_sse_env,(void*)):
	movl 4(%esp), %eax
	stmxcsr (%eax)
	ret

DEF(void,set_sse_env,(const void*)):
	movl 4(%esp), %eax
	ldmxcsr (%eax)
	ret

DEF(void,get_x87_env,(void*)):
	movl 4(%esp), %eax
	fnstsw (%eax)
	fnstcw 2(%eax)
	ret

DEF(void,set_x87_env,(const void*)):
	movl 4(%esp), %eax
	fnclex
	fldcw 2(%eax)
	ret

#include "cpu-x86.S"

#ifdef WINDOWS
	.section .drectve
	.ascii " -export:read_timestamp_counter"
	.ascii " -export:get_sse_env"
	.ascii " -export:set_sse_env"
	.ascii " -export:get_x87_env"
	.ascii " -export:set_x87_env"
#endif
