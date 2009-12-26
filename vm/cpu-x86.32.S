#include "asm.h"

#define DS_REG %esi
#define RS_REG %edi
#define RETURN_REG %eax

#define QUOT_XT_OFFSET 12

DEF(void,c_to_factor,(cell quot, void *vm)):
	/* Load parameters */
	mov 4(%esp),%eax
	mov 8(%esp),%edx

	/* Save non-volatile registers */
	push %ebx
	push %ebp
	push %esi
	push %edi

	/* Save old stack pointer and align */
	mov %esp,%ebp
	and $-16,%esp
	push %ebp

	/* Set up stack frame for the call to the boot quotation */
	sub $4,%esp
	push %edx
	push %eax

	/* Load context */
	mov (%edx),%ecx

	/* Load ctx->datastack */
	mov 8(%ecx),DS_REG

	/* Load ctx->retainstack */
	mov 12(%ecx),RS_REG

	/* Save ctx->callstack_bottom */
	lea -4(%esp),%ebx
	mov %ebx,4(%ecx)

	/* Call quot-xt */
	call *QUOT_XT_OFFSET(%eax)

	/* Tear down stack frame for the call to the boot quotation */
	pop %eax
	pop %edx
	add $4,%esp

	/* Undo stack alignment */
	pop %ebp
	mov %ebp,%esp

	/* Load context */
	mov (%edx),%ecx

	/* Save ctx->datastack */
	mov DS_REG,8(%ecx)

	/* Save ctx->retainstack */
	mov RS_REG,12(%ecx)

	/* Restore non-volatile registers */
	pop %edi
	pop %esi
	pop %ebp
	pop %ebx

	ret

DEF(void,set_callstack,(void *vm, stack_frame *to, stack_frame *from, cell length, void *memcpy)):
	/* load arguments */
	mov 4(%esp),%ebx  /* vm - to non-volatile register */
	mov 8(%esp),%ebp  /* to */
	mov 12(%esp),%edx /* from */
	mov 16(%esp),%ecx /* length */
	mov 20(%esp),%eax /* memcpy */

	/* compute new stack pointer */
	sub %ecx,%ebp
	mov %ebp,%esp

	/* call memcpy */
	push %ecx /* pass length */
	push %edx /* pass src */
	push %ebp /* pass dst */
	call *%eax
	add $12,%esp

	/* load context */
	mov (%ebx),%ecx
	/* load datastack */
	mov 8(%ecx),DS_REG
	/* load retainstack */
	mov 12(%ecx),RS_REG

	/* return with new stack */
	ret

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
	mov (%edx),%ecx
	/* load datastack */
	mov 8(%ecx),DS_REG
	/* load retainstack */
	mov 12(%ecx),RS_REG

	/* call the error handler */
	jmp *QUOT_XT_OFFSET(%eax)

DEF(void,lazy_jit_compile_impl,(cell quot, void *vm)):
	/* load context */
	mov (%edx),%ecx
	/* save datastack */
	mov DS_REG,8(%ecx)
	/* save retainstack */
	mov RS_REG,12(%ecx)
	/* save callstack */
	lea -4(%esp),%ebp
	mov %ebp,(%ecx)

	/* compile quotation */
	sub $4,%esp
	push %edx
	push %eax
	call MANGLE(lazy_jit_compile)
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
