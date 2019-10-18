#include "asm.h"

/* Callable from C as
void *native_stack_pointer(void) */
	.globl MANGLE(native_stack_pointer)
MANGLE(native_stack_pointer):
	mov %esp,%eax
	ret

/* Callable from C as
void execute(F_WORD *word) */
	.globl MANGLE(execute)
MANGLE(execute):
	mov 4(%esp),%eax
	push %ebx
	push %ebp
	push %eax
	call *32(%eax)
	pop %eax
	pop %ebp
	pop %ebx
	ret
