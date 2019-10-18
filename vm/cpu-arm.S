#include "asm.h"

/* Callable from C as
void *native_stack_pointer(void) */
	.globl MANGLE(native_stack_pointer)
MANGLE(native_stack_pointer):
	mov r0,sp
	mov pc,lr
