#include "asm.h"

/* Callable from C as
void *native_stack_pointer(void) */
	.globl MANGLE(native_stack_pointer)
MANGLE(native_stack_pointer):
	mov %rsp,%rax
	ret
