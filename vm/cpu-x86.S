/* Callable from C as
void *native_stack_pointer(void) */
	.globl native_stack_pointer
native_stack_pointer:
	mov %ebp,%eax
	ret
