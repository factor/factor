#include "asm.h"

#define ARG0 %eax
#define ARG1 %edx
#define ARG2 %ecx
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

DEF(void,primitive_inline_cache_miss,(void *vm)):
	mov (%esp),%ebx
DEF(void,primitive_inline_cache_miss_tail,(void *vm)):
	sub $8,%esp
	push ARG0   /* push vm ptr */
	push %ebx
	call MANGLE(inline_cache_miss)
	add $16,%esp
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

DEF(F_FASTCALL void,throw_impl,(CELL quot, F_STACK_FRAME *rewind_to, void *vm)):
	mov ARG2,NV_TEMP_REG  /* remember vm ptr in case quot_xt = lazy_jit_compile */		
	/* clear x87 stack, but preserve rounding mode and exception flags */
	sub $2,STACK_REG
	fnstcw (STACK_REG)
	fninit
	fldcw (STACK_REG)
	/* rewind_to */
	mov ARG1,STACK_REG
	mov NV_TEMP_REG,ARG1
	jmp *QUOT_XT_OFFSET(ARG0)

DEF(F_FASTCALL void,lazy_jit_compile,(CELL quot, void *vm)):
	mov ARG1,ARG2
	mov STACK_REG,ARG1           /* Save stack pointer */
	sub $STACK_PADDING,STACK_REG
	call MANGLE(lazy_jit_compile_impl)
	mov RETURN_REG,ARG0          /* No-op on 32-bit */
	add $STACK_PADDING,STACK_REG
    jmp *QUOT_XT_OFFSET(ARG0)    /* Call the quotation */

	
#include "cpu-x86.S"

#ifdef WINDOWS
	.section .drectve
	.ascii " -export:read_timestamp_counter"
	.ascii " -export:get_sse_env"
	.ascii " -export:set_sse_env"
	.ascii " -export:get_x87_env"
	.ascii " -export:set_x87_env"
#endif
