#include <ucontext.h>
#include <signal.h>
#include <sys/signal.h>
#include <machine/ucontext.h>
#include <sys/_ucontext.h>
#include <machine/fpu.h>

namespace factor {


inline static unsigned int uap_fpu_status(void *uap)
{
	ucontext_t *ucontext = (ucontext_t *)uap;
	if (ucontext->uc_mcontext.mc_fpformat == _MC_FPFMT_XMM)
	{
		struct savefpu *xmm = (struct savefpu *)(&ucontext->uc_mcontext.mc_fpstate);
		return xmm->sv_env.en_sw | xmm->sv_env.en_mxcsr;
	}
	else
		return 0;
}

inline static void uap_clear_fpu_status(void *uap)
{
	ucontext_t *ucontext = (ucontext_t *)uap;
	if (ucontext->uc_mcontext.mc_fpformat == _MC_FPFMT_XMM)
	{
		struct savefpu *xmm = (struct savefpu *)(&ucontext->uc_mcontext.mc_fpstate);
		xmm->sv_env.en_sw = 0;
		xmm->sv_env.en_mxcsr &= 0xffffffc0;
	}
}

#define UAP_STACK_POINTER(ucontext) (((struct sigcontext *)ucontext)->sc_rsp)
#define UAP_PROGRAM_COUNTER(ucontext) (((struct sigcontext *)ucontext)->sc_rip)
#define UAP_SET_TOC_POINTER(uap, ptr) (void)0
#define UAP_STACK_POINTER_TYPE long

static const unsigned JIT_FRAME_SIZE = 32;
}
