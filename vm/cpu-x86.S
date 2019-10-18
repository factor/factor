#if defined(__APPLE__) || defined(WINDOWS)
	#define MANGLE(sym) _##sym
#else
	#define MANGLE(sym) sym
#endif

/* Callable from C as
void *native_stack_pointer(void) */
	.globl MANGLE(native_stack_pointer)
MANGLE(native_stack_pointer):
	mov %esp,%eax
	ret
