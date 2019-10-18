#define SIGSEGV_EXC_STATE_TYPE ppc_exception_state_t
#define SIGSEGV_EXC_STATE_FLAVOR PPC_EXCEPTION_STATE
#define SIGSEGV_EXC_STATE_COUNT PPC_EXCEPTION_STATE_COUNT
#define SIGSEGV_THREAD_STATE_TYPE ppc_thread_state_t
#define SIGSEGV_THREAD_STATE_FLAVOR PPC_THREAD_STATE
#define SIGSEGV_THREAD_STATE_COUNT PPC_THREAD_STATE_COUNT
#define SIGSEGV_STACK_POINTER(thr_state) (thr_state).r1
#define SIGSEGV_PROGRAM_COUNTER(thr_state) (thr_state).srr0

INLINE unsigned long fix_stack_ptr(unsigned long sp)
{
	  return sp;
}
