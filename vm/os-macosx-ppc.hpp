#include <sys/ucontext.h>

namespace factor
{

/* Fault handler information.  MacOSX version.
Copyright (C) 1993-1999, 2002-2003  Bruno Haible <clisp.org at bruno>
Copyright (C) 2003  Paolo Bonzini <gnu.org at bonzini>

Used under BSD license with permission from Paolo Bonzini and Bruno Haible,
2005-03-10:

http://sourceforge.net/mailarchive/message.php?msg_name=200503102200.32002.bruno%40clisp.org

Modified for Factor by Slava Pestov */
#define FRAME_RETURN_ADDRESS(frame,vm) *((void **)(vm->frame_successor(frame) + 1) + 2)

#define MACH_EXC_STATE_TYPE ppc_exception_state_t
#define MACH_EXC_STATE_FLAVOR PPC_EXCEPTION_STATE
#define MACH_EXC_STATE_COUNT PPC_EXCEPTION_STATE_COUNT

#define MACH_EXC_INTEGER_DIV EXC_PPC_ZERO_DIVIDE

#define MACH_THREAD_STATE_TYPE ppc_thread_state_t
#define MACH_THREAD_STATE_FLAVOR PPC_THREAD_STATE
#define MACH_THREAD_STATE_COUNT PPC_THREAD_STATE_COUNT

#define MACH_FLOAT_STATE_TYPE ppc_float_state_t
#define MACH_FLOAT_STATE_FLAVOR PPC_FLOAT_STATE
#define MACH_FLOAT_STATE_COUNT PPC_FLOAT_STATE_COUNT

#if __DARWIN_UNIX03
	#define MACH_EXC_STATE_FAULT(exc_state) (exc_state)->__dar
	#define MACH_STACK_POINTER(thr_state) (thr_state)->__r1
	#define MACH_PROGRAM_COUNTER(thr_state) (thr_state)->__srr0

        #define UAP_SS(ucontext) &(((ucontext_t *)(ucontext))->uc_mcontext->__ss)
        #define UAP_FS(ucontext) &(((ucontext_t *)(ucontext))->uc_mcontext->__fs)

        #define FPSCR(float_state) (float_state)->__fpscr
#else
	#define MACH_EXC_STATE_FAULT(exc_state) (exc_state)->dar
	#define MACH_STACK_POINTER(thr_state) (thr_state)->r1
	#define MACH_PROGRAM_COUNTER(thr_state) (thr_state)->srr0

        #define UAP_SS(ucontext) &(((ucontext_t *)(ucontext))->uc_mcontext->ss)
        #define UAP_FS(ucontext) &(((ucontext_t *)(ucontext))->uc_mcontext->fs)

        #define FPSCR(float_state) (float_state)->fpscr
#endif

#define UAP_PROGRAM_COUNTER(ucontext) \
        MACH_PROGRAM_COUNTER(UAP_SS(ucontext))

inline static unsigned int mach_fpu_status(ppc_float_state_t *float_state)
{
	return FPSCR(float_state);
}

inline static unsigned int uap_fpu_status(void *uap)
{
	return mach_fpu_status(UAP_FS(uap));
}

inline static cell fix_stack_pointer(cell sp)
{
	return sp;
}

inline static void mach_clear_fpu_status(ppc_float_state_t *float_state)
{
	FPSCR(float_state) &= 0x0007f8ff;
}

inline static void uap_clear_fpu_status(void *uap)
{
	mach_clear_fpu_status(UAP_FS(uap));
}

}
