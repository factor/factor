#pragma once
#include <signal.h>
#include <ucontext.h>

namespace factor {

inline static unsigned int uap_fpu_status(void* uap) {
  auto* context = static_cast<ucontext_t*>(uap);
  return context->uc_mcontext.fpregs->swd |
         context->uc_mcontext.fpregs->mxcsr;
}

inline static void uap_clear_fpu_status(void* uap) {
  auto* context = static_cast<ucontext_t*>(uap);
  context->uc_mcontext.fpregs->swd = 0;
  context->uc_mcontext.fpregs->mxcsr &= 0xffffffc0;
}

#define UAP_STACK_POINTER(uap) \
  (static_cast<ucontext_t*>(uap)->uc_mcontext.gregs[REG_RSP])
#define UAP_PROGRAM_COUNTER(uap) \
  (static_cast<ucontext_t*>(uap)->uc_mcontext.gregs[REG_RIP])

#define CODE_TO_FUNCTION_POINTER(code) (void)0
#define CODE_TO_FUNCTION_POINTER_CALLBACK(vm, code) (void)0
#define FUNCTION_CODE_POINTER(ptr) ptr
#define FUNCTION_TOC_POINTER(ptr) ptr

static const unsigned JIT_FRAME_SIZE = 32;

}
