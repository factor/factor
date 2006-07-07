#define SIGSEGV_EXC_STATE_TYPE i386_exception_state_t
#define SIGSEGV_EXC_STATE_FLAVOR i386_EXCEPTION_STATE
#define SIGSEGV_EXC_STATE_COUNT i386_EXCEPTION_STATE_COUNT
#define SIGSEGV_THREAD_STATE_TYPE i386_thread_state_t
#define SIGSEGV_THREAD_STATE_FLAVOR i386_THREAD_STATE
#define SIGSEGV_THREAD_STATE_COUNT i386_THREAD_STATE_COUNT
#define SIGSEGV_STACK_POINTER(thr_state) (thr_state).esp
#define SIGSEGV_PROGRAM_COUNTER(thr_state) (thr_state).eip

INLINE void fix_stack_ptr(unsigned long sp)
{
	  if ((sp & 0xf) != 0) sp -= (sp & 0xf);
	  sp -= 4;
	  return sp;
}
