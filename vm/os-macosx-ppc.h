typedef struct _F_STACK_FRAME {
	struct _F_STACK_FRAME *previous;
	CELL padding1;
	CELL *return_address;
	CELL padding2;
} F_STACK_FRAME;

#define SIGSEGV_EXC_STATE_TYPE ppc_exception_state_t
#define SIGSEGV_EXC_STATE_FLAVOR PPC_EXCEPTION_STATE
#define SIGSEGV_EXC_STATE_COUNT PPC_EXCEPTION_STATE_COUNT
#define SIGSEGV_EXC_STATE_FAULT(exc_state) (exc_state).dar
#define SIGSEGV_THREAD_STATE_TYPE ppc_thread_state_t
#define SIGSEGV_THREAD_STATE_FLAVOR PPC_THREAD_STATE
#define SIGSEGV_THREAD_STATE_COUNT PPC_THREAD_STATE_COUNT
#define SIGSEGV_STACK_POINTER(thr_state) (thr_state).r1
#define SIGSEGV_THREAD_STATE_ARG(thr_state) (thr_state).r3
#define SIGSEGV_PROGRAM_COUNTER(thr_state) (thr_state).srr0

INLINE unsigned long fix_stack_ptr(unsigned long sp)
{
	  return sp;
}

INLINE void pass_arg0(SIGSEGV_THREAD_STATE_TYPE *thr_state, CELL arg)
{
	SIGSEGV_THREAD_STATE_ARG(*thr_state) = arg;
}
