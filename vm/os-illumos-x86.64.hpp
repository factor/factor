#pragma once
#include <ucontext.h>

namespace factor {

inline static unsigned int uap_fpu_status(void* uap) {
  auto& state = ((ucontext_t*)uap)->uc_mcontext.fpregs.fp_reg_set.fpchip_state;
  return state.status | state.xstatus;
}

inline static void uap_clear_fpu_status(void* uap) {
  auto& state = ((ucontext_t*)uap)->uc_mcontext.fpregs.fp_reg_set.fpchip_state;
  state.sw = 0;
  state.status = 0;
  state.mxcsr &= 0xffffffc0;
  state.xstatus = 0;
}

#define UAP_STACK_POINTER(uap) (((ucontext_t*)uap)->uc_mcontext.gregs[REG_RSP])
#define UAP_PROGRAM_COUNTER(uap) (((ucontext_t*)uap)->uc_mcontext.gregs[REG_RIP])

static const unsigned JIT_FRAME_SIZE = 32;

}
