#include "asm.h"

#define DS_REG %r14
#define RS_REG %r15
#define RETURN_REG %rax

#define QUOT_XT_OFFSET 28

#ifdef WINDOWS

	#define ARG0 %rcx
	#define ARG1 %rdx
	#define ARG2 %r8
	#define ARG3 %r9

	#define PUSH_NONVOLATILE \
		push %r15 ; \
		push %r14 ; \
		push %r12 ; \
		push %r13 ; \
		push %rdi ; \
		push %rsi ; \
		push %rbx ; \
		push %rbp

	#define POP_NONVOLATILE \
		pop %rbp ; \
		pop %rbx ; \
		pop %rsi ; \
		pop %rdi ; \
		pop %r13 ; \
		pop %r12 ; \
		pop %r14 ; \
		pop %r15

#else

	#define ARG0 %rdi
	#define ARG1 %rsi
	#define ARG2 %rdx
	#define ARG3 %rcx

	#define PUSH_NONVOLATILE \
		push %rbx ; \
		push %rbp ; \
		push %r12 ; \
		push %r13 ; \
		push %r14 ; \
		push %r15

	#define POP_NONVOLATILE \
		pop %r15 ; \
		pop %r14 ; \
		pop %r13 ; \
		pop %r12 ; \
		pop %rbp ; \
		pop %rbx

#endif

DEF(void,c_to_factor,(cell quot, void *vm)):
	PUSH_NONVOLATILE

	/* Save old stack pointer and align */
	mov %rsp,%rbp
	and $-16,%rsp
	push %rbp

	/* Set up stack frame for the call to the boot quotation */
	push ARG0
	push ARG1

	/* Create register shadow area (required for Win64 only) */
	sub $40,%rsp

	/* Load context */
	mov (ARG1),ARG2

	/* Save ctx->callstack_bottom */
	lea -8(%rsp),ARG3
	mov ARG3,8(ARG2)

	/* Load ctx->datastack */
	mov 16(ARG2),DS_REG

	/* Load ctx->retainstack */
	mov 24(ARG2),RS_REG

	/* Call quot-xt */
	call *QUOT_XT_OFFSET(ARG0)

	/* Tear down register shadow area */
	add $40,%rsp

	/* Tear down stack frame for the call to the boot quotation */
	pop ARG1
	pop ARG0

	/* Undo stack alignment */
	pop %rbp
	mov %rbp,%rsp

	/* Load context */
	mov (ARG1),ARG2

	/* Save ctx->datastack */
	mov DS_REG,16(ARG2)

	/* Save ctx->retainstack */
	mov RS_REG,24(ARG2)

	POP_NONVOLATILE
	ret

DEF(void,set_callstack,(void *vm, stack_frame *to, stack_frame *from, cell length)):
	/* save VM pointer in non-volatile register */
	mov ARG0,%rbp

	/* compute new stack pointer */	
	sub ARG3,ARG1
	mov ARG1,%rsp

	/* call memcpy */
	mov ARG1,ARG0
	mov ARG2,ARG1
	mov ARG3,ARG2
	call MANGLE(memcpy)

	/* load context */
	mov (%rbp),ARG2
	/* load datastack */
	mov 16(ARG2),DS_REG
	/* load retainstack */
	mov 24(ARG2),RS_REG

	/* return with new stack */
	ret

DEF(void,throw_impl,(cell quot, void *new_stack, void *vm)):
	/* clear x87 stack, but preserve rounding mode and exception flags */
	sub $2,%rsp
	fnstcw (%rsp)
	fninit
	fldcw (%rsp)

	/* shuffle args */
	mov ARG1,%rsp
	mov ARG2,ARG1

	/* load context */
	mov (ARG1),ARG2
	/* load datastack */
	mov 16(ARG2),DS_REG
	/* load retainstack */
	mov 24(ARG2),RS_REG

	jmp *QUOT_XT_OFFSET(ARG0)

DEF(void,lazy_jit_compile_impl,(cell quot, void *vm)):
	/* load context */
	mov (ARG1),ARG2
	/* save datastack */
	mov DS_REG,16(ARG2)
	/* save retainstack */
	mov RS_REG,24(ARG2)
	/* save callstack */
	lea -8(%rsp),%rbp
	mov %rbp,(ARG2)

	/* compile quotation */
	sub $8,%rsp
	call MANGLE(lazy_jit_compile)
	add $8,%rsp

	/* call quotation */
	jmp *QUOT_XT_OFFSET(RETURN_REG)

DEF(long long,read_timestamp_counter,(void)):
	mov $0,%rax
	rdtsc
	shl $32,%rdx
	or %rdx,%rax
	ret

DEF(void,get_sse_env,(void*)):
	stmxcsr (%rdi)
	ret

DEF(void,set_sse_env,(const void*)):
	ldmxcsr (%rdi)
	ret

DEF(void,get_x87_env,(void*)):
	fnstsw (%rdi)
	fnstcw 2(%rdi)
	ret

DEF(void,set_x87_env,(const void*)):
	fnclex
	fldcw 2(%rdi)
	ret
	
#include "cpu-x86.S"
