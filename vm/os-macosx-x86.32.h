#define MACH_EXC_STATE_TYPE i386_exception_state_t
#define MACH_EXC_STATE_FLAVOR i386_EXCEPTION_STATE
#define MACH_EXC_STATE_COUNT i386_EXCEPTION_STATE_COUNT
#define MACH_THREAD_STATE_TYPE i386_thread_state_t
#define MACH_THREAD_STATE_FLAVOR i386_THREAD_STATE
#define MACH_THREAD_STATE_COUNT i386_THREAD_STATE_COUNT

#if __DARWIN_UNIX03
    #define MACH_EXC_STATE_FAULT(exc_state) (exc_state)->__faultvaddr
    #define MACH_STACK_POINTER(thr_state) (thr_state)->__esp
    #define MACH_PROGRAM_COUNTER(thr_state) (thr_state)->__eip
	#define UAP_PROGRAM_COUNTER(ucontext) \
		MACH_PROGRAM_COUNTER(&(((ucontext_t *)(ucontext))->uc_mcontext->__ss))
#else
    #define MACH_EXC_STATE_FAULT(exc_state) (exc_state)->faultvaddr
    #define MACH_STACK_POINTER(thr_state) (thr_state)->esp
    #define MACH_PROGRAM_COUNTER(thr_state) (thr_state)->eip
	#define UAP_PROGRAM_COUNTER(ucontext) \
		MACH_PROGRAM_COUNTER(&(((ucontext_t *)(ucontext))->uc_mcontext->ss))	
#endif
