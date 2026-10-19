#pragma once
#include "os-netbsd.hpp"

namespace factor {
#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr
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
}
