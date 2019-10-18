#include <ucontext.h>

namespace factor {

// glibc lies about the contents of the fpstate the kernel provides, hiding the
// FXSR
// environment
struct _fpstate {
  // Regular FPU environment
  unsigned long cw;
  unsigned long sw;
  unsigned long tag;
  unsigned long ipoff;
  unsigned long cssel;
  unsigned long dataoff;
  unsigned long datasel;
  struct _fpreg _st[8];
  unsigned short status;
  unsigned short magic; // 0xffff = regular FPU data only

  // FXSR FPU environment
  unsigned long _fxsr_env[6]; // FXSR FPU env is ignored
  unsigned long mxcsr;
  unsigned long reserved;
  struct _fpxreg _fxsr_st[8]; // FXSR FPU reg data is ignored
  struct _xmmreg _xmm[8];
  unsigned long padding[56];
};

#define X86_FXSR_MAGIC 0x0000

inline static unsigned int uap_fpu_status(void* uap) {
  ucontext_t* ucontext = (ucontext_t*)uap;
  struct _fpstate* fpregs = (struct _fpstate*)ucontext->uc_mcontext.fpregs;
  if (fpregs->magic == X86_FXSR_MAGIC)
    return fpregs->sw | fpregs->mxcsr;
  else
    return fpregs->sw;
}

inline static void uap_clear_fpu_status(void* uap) {
  ucontext_t* ucontext = (ucontext_t*)uap;
  struct _fpstate* fpregs = (struct _fpstate*)ucontext->uc_mcontext.fpregs;
  fpregs->sw = 0;
  if (fpregs->magic == X86_FXSR_MAGIC)
    fpregs->mxcsr &= 0xffffffc0;
}

#define UAP_STACK_POINTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.gregs[7])
#define UAP_PROGRAM_COUNTER(ucontext) \
  (((ucontext_t*)ucontext)->uc_mcontext.gregs[14])

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

}
