extern void *primitives[];

/* Primitives are called with two parameters, the word itself and the current
callstack pointer. The DEFINE_PRIMITIVE() macro takes care of boilerplate to
save the current callstack pointer so that GC and other facilities can proceed
to inspect Factor stack frames below the primitive's C stack frame.

Usage:

DEFINE_PRIMITIVE(name)
{
	... CODE ...
}

Becomes

F_FASTCALL void primitive_name(CELL word, F_STACK_FRAME *callstack_top)
{
	stack_chain->callstack_top = callstack_top;
	... CODE ...
}

On x86, F_FASTCALL expands into a GCC declaration which forces the two
parameters to be passed in registers. This simplifies the quotation compiler
and support code in cpu-x86.S. */
#define DEFINE_PRIMITIVE(name) \
	INLINE void primitive_##name##_impl(void); \
	\
	F_FASTCALL void primitive_##name(CELL word, F_STACK_FRAME *callstack_top) \
	{ \
		stack_chain->callstack_top = callstack_top; \
		primitive_##name##_impl(); \
	} \
	\
	INLINE void primitive_##name##_impl(void) \

/* Prototype for header files */
#define DECLARE_PRIMITIVE(name) \
	F_FASTCALL void primitive_##name(CELL word, F_STACK_FRAME *callstack_top)
