INLINE void *openbsd_stack_pointer(void *uap)
{
	ucontext_t *ucontext = (ucontext_t *)uap;
	return (void *)ucontext->sc_esp;
}

#define ucontext_stack_pointer openbsd_stack_pointer
