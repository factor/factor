#include <ucontext.h>
#include <sys/mman.h>
namespace factor {
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
#if defined(FACTOR_ARM64)
#define UAP_STACK_POINTER(uap) (((ucontext_t*)uap)->uc_mcontext.__gregs[_REG_SP])
#define UAP_PROGRAM_COUNTER(uap) (((ucontext_t*)uap)->uc_mcontext.__gregs[_REG_PC])
inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char*)start, (char*)(start + len));
}
inline static unsigned int uap_fpu_status(void* uap) {
  return ((ucontext_t*)uap)->uc_mcontext.__fregs.__fpsr;
}
inline static void uap_clear_fpu_status(void* uap) {
  ((ucontext_t*)uap)->uc_mcontext.__fregs.__fpsr = 0;
}
inline static unsigned int fpu_status(unsigned int status) {
  unsigned int result = 0;
  if (status & 1) result |= FP_TRAP_INVALID_OPERATION;
  if (status & 2) result |= FP_TRAP_ZERO_DIVIDE;
  if (status & 4) result |= FP_TRAP_OVERFLOW;
  if (status & 8) result |= FP_TRAP_UNDERFLOW;
  if (status & 16) result |= FP_TRAP_INEXACT;
  return result;
}
#elif defined(FACTOR_ARM32)
#define UAP_STACK_POINTER(uap) (((ucontext_t*)uap)->uc_mcontext.__gregs[_REG_SP])
#define UAP_PROGRAM_COUNTER(uap) (((ucontext_t*)uap)->uc_mcontext.__gregs[_REG_PC])
inline static void flush_icache(cell start, cell len) {
  __builtin___clear_cache((char*)start, (char*)(start + len));
}
inline static unsigned int uap_fpu_status(void* uap) {
  auto uc = (ucontext_t*)uap;
  return (uc->uc_flags & _UC_ARM_VFP) ? uc->uc_mcontext.__fpu.__vfpregs.__vfp_fpscr : 0;
}
inline static void uap_clear_fpu_status(void* uap) {
  auto uc = (ucontext_t*)uap;
  if (uc->uc_flags & _UC_ARM_VFP) uc->uc_mcontext.__fpu.__vfpregs.__vfp_fpscr &= ~0x9fu;
}
inline static unsigned int fpu_status(unsigned int status) {
  unsigned int result = 0;
  if (status & 1) result |= FP_TRAP_INVALID_OPERATION;
  if (status & 2) result |= FP_TRAP_ZERO_DIVIDE;
  if (status & 4) result |= FP_TRAP_OVERFLOW;
  if (status & 8) result |= FP_TRAP_UNDERFLOW;
  if (status & 16) result |= FP_TRAP_INEXACT;
  return result;
}
#else
#if defined(FACTOR_AMD64)
static const unsigned JIT_FRAME_SIZE = 32;
#define UAP_STACK_POINTER(uap) (((ucontext_t*)uap)->uc_mcontext.__gregs[_REG_RSP])
#define UAP_PROGRAM_COUNTER(uap) (((ucontext_t*)uap)->uc_mcontext.__gregs[_REG_RIP])
#else
#define UAP_STACK_POINTER(uap) (((ucontext_t*)uap)->uc_mcontext.__gregs[_REG_UESP])
#define UAP_PROGRAM_COUNTER(uap) (((ucontext_t*)uap)->uc_mcontext.__gregs[_REG_EIP])
#endif
inline static unsigned int uap_fpu_status(void* uap) {
  unsigned char* fp = (unsigned char*)&((ucontext_t*)uap)->uc_mcontext.__fpregs;
  unsigned short sw; unsigned int mxcsr;
#if defined(FACTOR_X86)
  if (!(((ucontext_t*)uap)->uc_flags & _UC_FXSAVE)) {
    memcpy(&sw, fp + 4, sizeof(sw)); return sw;
  }
#endif
  memcpy(&sw, fp + 2, sizeof(sw)); memcpy(&mxcsr, fp + 24, sizeof(mxcsr));
  return sw | mxcsr;
}
inline static void uap_clear_fpu_status(void* uap) {
  unsigned char* fp = (unsigned char*)&((ucontext_t*)uap)->uc_mcontext.__fpregs;
  unsigned short sw = 0; unsigned int mxcsr;
#if defined(FACTOR_X86)
  if (!(((ucontext_t*)uap)->uc_flags & _UC_FXSAVE)) {
    memcpy(fp + 4, &sw, sizeof(sw)); return;
  }
#endif
  memcpy(&mxcsr, fp + 24, sizeof(mxcsr)); mxcsr &= 0xffffffc0;
  memcpy(fp + 2, &sw, sizeof(sw)); memcpy(fp + 24, &mxcsr, sizeof(mxcsr));
}
#endif
}
