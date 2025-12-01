#include <sys/ucontext.h>

namespace factor {

// Fault handler information.  macOS version.
// Copyright (C) 1993-1999, 2002-2003  Bruno Haible <clisp.org at bruno>
// Copyright (C) 2003  Paolo Bonzini <gnu.org at bonzini>

// Used under BSD license with permission from Paolo Bonzini and Bruno Haible,
// 2005-03-10:

// http://sourceforge.net/mailarchive/message.php?msg_name=200503102200.32002.bruno%40clisp.org

// Modified for Factor by Slava Pestov
#define MACH_EXC_STATE_TYPE i386_exception_state_t
#define MACH_EXC_STATE_FLAVOR i386_EXCEPTION_STATE
#define MACH_EXC_STATE_COUNT i386_EXCEPTION_STATE_COUNT

#define MACH_EXC_INTEGER_DIV EXC_I386_DIV

#define MACH_THREAD_STATE_TYPE i386_thread_state_t
#define MACH_THREAD_STATE_FLAVOR i386_THREAD_STATE
#define MACH_THREAD_STATE_COUNT i386_THREAD_STATE_COUNT

#define MACH_FLOAT_STATE_TYPE i386_float_state_t
#define MACH_FLOAT_STATE_FLAVOR i386_FLOAT_STATE
#define MACH_FLOAT_STATE_COUNT i386_FLOAT_STATE_COUNT

#if __DARWIN_UNIX03
#define MACH_EXC_STATE_FAULT(exc_state) (exc_state)->__faultvaddr
#define MACH_STACK_POINTER(thr_state) (thr_state)->__esp
#define MACH_PROGRAM_COUNTER(thr_state) (thr_state)->__eip

#define UAP_SS(ucontext) &(((ucontext_t*)(ucontext))->uc_mcontext->__ss)
#define UAP_FS(ucontext) &(((ucontext_t*)(ucontext))->uc_mcontext->__fs)

#define MXCSR(float_state) (float_state)->__fpu_mxcsr
#define X87SW(float_state) (float_state)->__fpu_fsw
#else
#define MACH_EXC_STATE_FAULT(exc_state) (exc_state)->faultvaddr
#define MACH_STACK_POINTER(thr_state) (thr_state)->esp
#define MACH_PROGRAM_COUNTER(thr_state) (thr_state)->eip

#define UAP_SS(ucontext) &(((ucontext_t*)(ucontext))->uc_mcontext->ss)
#define UAP_FS(ucontext) &(((ucontext_t*)(ucontext))->uc_mcontext->fs)

#define MXCSR(float_state) (float_state)->fpu_mxcsr
#define X87SW(float_state) (float_state)->fpu_fsw
#endif

#define UAP_PROGRAM_COUNTER(ucontext) MACH_PROGRAM_COUNTER(UAP_SS(ucontext))

inline static unsigned int mach_fpu_status(i386_float_state_t* float_state) {
  unsigned short x87sw;
  memcpy(&x87sw, &X87SW(float_state), sizeof(x87sw));
  return MXCSR(float_state) | x87sw;
}

inline static unsigned int uap_fpu_status(void* uap) {
  return mach_fpu_status(UAP_FS(uap));
}

inline static void mach_clear_fpu_status(i386_float_state_t* float_state) {
  MXCSR(float_state) &= 0xffffffc0;
  memset(&X87SW(float_state), 0, sizeof(X87SW(float_state)));
}

inline static void uap_clear_fpu_status(void* uap) {
  mach_clear_fpu_status(UAP_FS(uap));
}

}
