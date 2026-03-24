#include <sys/ucontext.h>

namespace factor {

inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char *)start, (char *)(start + len));
}

#define MACH_EXC_INTEGER_DIV EXC_ARM_FP_DZ
#define MACH_EXC_STATE_TYPE _STRUCT_ARM_EXCEPTION_STATE64
#define MACH_EXC_STATE_FAULT(exc_state) (exc_state)->__far
#define MACH_EXC_STATE_COUNT ARM_EXCEPTION_STATE64_COUNT
#define MACH_EXC_STATE_FLAVOR ARM_EXCEPTION_STATE64

#define MACH_THREAD_STATE_TYPE _STRUCT_ARM_THREAD_STATE64
#define MACH_THREAD_STATE_COUNT MACHINE_THREAD_STATE_COUNT
#define MACH_THREAD_STATE_FLAVOR ARM_THREAD_STATE64

#define MACH_FLOAT_STATE_TYPE _STRUCT_ARM_NEON_STATE64
#define MACH_FLOAT_STATE_COUNT ARM_NEON_STATE64_COUNT
#define MACH_FLOAT_STATE_FLAVOR ARM_NEON_STATE64

#define MACH_STACK_POINTER(thr_state) (thr_state)->__sp

#define MACH_PROGRAM_COUNTER(thr_state) (thr_state)->__pc
#define UAP_PROGRAM_COUNTER(ucontext) MACH_PROGRAM_COUNTER(UAP_SS(ucontext))

#define UAP_SS(ucontext) &(((ucontext_t*)(ucontext))->uc_mcontext->__ss)
#define UAP_ES(ucontext) (&(((ucontext_t*)(ucontext))->uc_mcontext->__es))
#define UAP_FS(ucontext) &(((ucontext_t*)(ucontext))->uc_mcontext->__ns)

inline static unsigned int mach_fpu_status(arm_neon_state64_t* float_state) {
  return float_state->__fpsr;
}

inline static unsigned int arm_fp_status_from_esr(unsigned int esr) {
  const unsigned int ec = esr >> 26;
  return ec == 0x2c ? (esr & 0x1f) : 0;
}

inline static unsigned int mach_fp_trap_status(arm_exception_state64_t* exc_state,
                                               arm_neon_state64_t* float_state) {
  unsigned int status = mach_fpu_status(float_state);
  return status != 0 ? status : arm_fp_status_from_esr(exc_state->__esr);
}

inline static unsigned int uap_fpu_status(void* uap) {
  return mach_fpu_status(UAP_FS(uap));
}

inline static unsigned int uap_fp_trap_status(void* uap) {
  unsigned int status = uap_fpu_status(uap);
  return status != 0 ? status : arm_fp_status_from_esr(UAP_ES(uap)->__esr);
}

inline static void mach_clear_fpu_status(arm_neon_state64_t* float_state) {
  float_state->__fpsr = 0;
}

inline static void uap_clear_fpu_status(void* uap) {
  mach_clear_fpu_status(UAP_FS(uap));
}

inline static unsigned int fpu_status(unsigned int status) {
  unsigned int r = 0;

  if (status & 0x01)
    r |= FP_TRAP_INVALID_OPERATION;
  if (status & 0x02)
    r |= FP_TRAP_ZERO_DIVIDE;
  if (status & 0x04)
    r |= FP_TRAP_OVERFLOW;
  if (status & 0x08)
    r |= FP_TRAP_UNDERFLOW;
  if (status & 0x10)
    r |= FP_TRAP_INEXACT;

  return r;
}

}
