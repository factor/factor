#include "asm.h"

#define STACK_REG %rsp
#define DS_REG %r14
#define RETURN_REG %rax

#define CELL_SIZE 8
#define STACK_PADDING 56

#define NV_TEMP_REG %rbp

#define ARITH_TEMP_1 %r8
#define ARITH_TEMP_2 %r9
#define DIV_RESULT %rax

#ifdef WINDOWS

	#define ARG0 %rcx
	#define ARG1 %rdx
	#define ARG2 %r8
	#define ARG3 %r9

	#define PUSH_NONVOLATILE \
		push %r12 ; \
		push %r13 ; \
		push %rdi ; \
		push %rsi ; \
		push %rbx ; \
		push %rbp ; \
		push %rbp

	#define POP_NONVOLATILE \
		pop %rbp ; \
		pop %rbp ; \
		pop %rbx ; \
		pop %rsi ; \
		pop %rdi ; \
		pop %r13 ; \
		pop %r12

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
		push %r13

	#define POP_NONVOLATILE \
		pop %r13 ; \
		pop %r13 ; \
		pop %r12 ; \
		pop %rbp ; \
		pop %rbx

#endif

#define QUOT_XT_OFFSET 28

/* We pass a function pointer to memcpy to work around a Mac OS X
ABI limitation which would otherwise require us to do a bizzaro PC-relative
trampoline to retrieve the function address */
DEF(void,set_callstack,(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy)):
	sub ARG2,ARG0                      /* compute new stack pointer */
	mov ARG0,%rsp
	call *ARG3                         /* call memcpy */
	ret                                /* return _with new stack_ */

DEF(long long,read_timestamp_counter,(void)):
	mov $0,%rax
	rdtsc
	shl $32,%rdx
	or %rdx,%rax
	ret

DEF(void,primitive_inline_cache_miss,(void *vm)):
	mov (%rsp),%rbx
DEF(void,primitive_inline_cache_miss_tail,(void *vm)):
	sub $STACK_PADDING,%rsp
	mov ARG0,ARG1
	mov %rbx,ARG0
	call MANGLE(inline_cache_miss)
	add $STACK_PADDING,%rsp
	jmp *%rax

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

DEF(F_FASTCALL void,throw_impl,(CELL quot, F_STACK_FRAME *rewind_to, void *vm)):
	/* clear x87 stack, but preserve rounding mode and exception flags */
	sub $2,STACK_REG
	fnstcw (STACK_REG)
	fninit
	fldcw (STACK_REG)
	/* rewind_to */
	mov ARG1,STACK_REG
	mov ARG2,ARG1  /* make vm ptr 2nd arg in case quot_xt = lazy_jit_compile */
	jmp *QUOT_XT_OFFSET(ARG0)

DEF(F_FASTCALL void,lazy_jit_compile,(CELL quot, void *vm)):
	mov ARG1,ARG2                /* vm is 3rd arg */
	mov STACK_REG,ARG1           /* Save stack pointer */
	sub $STACK_PADDING,STACK_REG
	call MANGLE(lazy_jit_compile_impl)
	mov RETURN_REG,ARG0          /* No-op on 32-bit */
	add $STACK_PADDING,STACK_REG
        jmp *QUOT_XT_OFFSET(ARG0)    /* Call the quotation */

	
#include "cpu-x86.S"
