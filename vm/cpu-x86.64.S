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

DEF(void,primitive_inline_cache_miss,(void)):
	mov (%rsp),%rbx
DEF(void,primitive_inline_cache_miss_tail,(void)):
	sub $STACK_PADDING,%rsp
	mov %rbx,ARG0
	call MANGLE(inline_cache_miss)
	add $STACK_PADDING,%rsp
	jmp *%rax

#include "cpu-x86.S"
