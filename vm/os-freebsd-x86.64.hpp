#include <ucontext.h>
#include <machine/fpu.h>

namespace factor
{

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


#define UAP_STACK_POINTER(ucontext) (((ucontext_t *)ucontext)->uc_mcontext.mc_rsp)
#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t *)ucontext)->uc_mcontext.mc_rip)

}
