#include <ucontext.h>
#include <signal.h>
#include <machine/npx.h>

namespace factor {
inline static unsigned int uap_fpu_status(void *uap)
{
  auto *uc = static_cast<ucontext_t *>(uap);
  if (uc->uc_mcontext.mc_fpformat != _MC_FPFMT_XMM &&
      uc->uc_mcontext.mc_fpformat != _MC_FPFMT_YMM) return 0;
  auto *fp = reinterpret_cast<union savefpu *>(uc->uc_mcontext.mc_fpregs);
  return fp->sv_xmm64.sv_env.en_sw | fp->sv_xmm64.sv_env.en_mxcsr;
}
inline static void uap_clear_fpu_status(void *uap)
{
  auto *uc = static_cast<ucontext_t *>(uap);
  if (uc->uc_mcontext.mc_fpformat != _MC_FPFMT_XMM &&
      uc->uc_mcontext.mc_fpformat != _MC_FPFMT_YMM) return;
  auto *fp = reinterpret_cast<union savefpu *>(uc->uc_mcontext.mc_fpregs);
  fp->sv_xmm64.sv_env.en_sw = 0;
  fp->sv_xmm64.sv_env.en_mxcsr &= 0xffffffc0;
}
#define UAP_STACK_POINTER(ucontext) (static_cast<ucontext_t *>(ucontext)->uc_mcontext.mc_rsp)
#define UAP_PROGRAM_COUNTER(ucontext) (static_cast<ucontext_t *>(ucontext)->uc_mcontext.mc_rip)
#define UAP_SET_TOC_POINTER(uap, ptr) (void)0
#define UAP_STACK_POINTER_TYPE long
static const unsigned JIT_FRAME_SIZE = 32;
}
