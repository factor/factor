#include "asm.h"

#define ARG0 %eax
#define ARG1 %edx
#define ARG2 %ecx
#define STACK_REG %esp
#define DS_REG %esi
#define RS_REG %edi
#define RETURN_REG %eax

#define NV0 %ebx
#define NV1 %ebp

#define CELL_SIZE 4
#define STACK_PADDING 12

#define PUSH_NONVOLATILE \
	push %ebx ; \
	push %ebp ; \
	push %esi ; \
	push %edi

#define POP_NONVOLATILE \
	pop %edi ; \
	pop %esi ; \
	pop %ebp ; \
	pop %ebx

#define QUOT_XT_OFFSET 12

DEF(void,set_callstack,(void *vm, stack_frame *to, stack_frame *from, cell length, void *memcpy)):
	mov 4(%esp),%ebx                   /* vm */
	mov 8(%esp),%ebp                   /* to */
	mov 12(%esp),%edx                  /* from */
	mov 16(%esp),%ecx                  /* length */
	mov 20(%esp),%eax                  /* memcpy */
	sub %ecx,%ebp                      /* compute new stack pointer */
	mov %ebp,%esp
	push %ecx                          /* pass length */
	push %edx                          /* pass src */
	push %ebp                          /* pass dst */
	call *%eax                         /* call memcpy */
	add $12,%esp                       /* pop args from the stack */
	mov (%ebx),%ebx                    /* load context */
	mov 8(%ebx),DS_REG                 /* load datastack */
	mov 12(%ebx),RS_REG                /* load retainstack */
	ret                                /* return _with new stack_ */

DEF(void,throw_impl,(cell quot, void *new_stack, void *vm)):
	/* clear x87 stack, but preserve rounding mode and exception flags */
	sub $2,%esp
	fnstcw (%esp)
	fninit
	fldcw (%esp)
	add $2,%esp
	/* load quotation and vm parameters */
	mov 4(%esp),%eax
	mov 12(%esp),%edx
	/* load new stack pointer */
	mov 8(%esp),%esp
	/* load context */
	mov (%edx),%ebx
	/* load datastack */
	mov 8(%ebx),DS_REG
	/* load retainstack */
	mov 12(%ebx),RS_REG
	/* call the error handler */
	jmp *QUOT_XT_OFFSET(%eax)

DEF(VM_ASM_API void,lazy_jit_compile,(cell quot, void *vm)):
	/* load context */
	mov (ARG1),%ebx
	/* save callstack */
	lea -4(%esp),%ebp
	mov %ebp,(%ebx)
	/* save datastack */
	mov DS_REG,8(%ebx)
	/* save retainstack */
	mov RS_REG,12(%ebx)
	/* compile quotation */
	sub $4,%esp
	push ARG1
	push ARG0
	call MANGLE(lazy_jit_compile_impl)
	add $12,%esp
	/* call quotation */
	jmp *QUOT_XT_OFFSET(%eax)

DEF(long long,read_timestamp_counter,(void)):
	rdtsc
	ret

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
