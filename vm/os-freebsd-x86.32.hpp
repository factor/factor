#include <ucontext.h>
#include <machine/npx.h>

namespace factor
{

inline static unsigned int uap_fpu_status(void *uap)
{
	ucontext_t *ucontext = (ucontext_t *)uap;
	if (ucontext->uc_mcontext.mc_fpformat == _MC_FPFMT_387)
	{
		struct save87 *x87 = (struct save87 *)(&ucontext->uc_mcontext.mc_fpstate);
		return x87->sv_env.en_sw;
	}
	else if (ucontext->uc_mcontext.mc_fpformat == _MC_FPFMT_XMM)
	{
		struct savexmm *xmm = (struct savexmm *)(&ucontext->uc_mcontext.mc_fpstate);
		return xmm->sv_env.en_sw | xmm->sv_env.en_mxcsr;
	}
	else
		return 0;
}

inline static void uap_clear_fpu_status(void *uap)
{
	ucontext_t *ucontext = (ucontext_t *)uap;
	if (ucontext->uc_mcontext.mc_fpformat == _MC_FPFMT_387)
	{
		struct save87 *x87 = (struct save87 *)(&ucontext->uc_mcontext.mc_fpstate);
		x87->sv_env.en_sw = 0;
	}
	else if (ucontext->uc_mcontext.mc_fpformat == _MC_FPFMT_XMM)
	{
		struct savexmm *xmm = (struct savexmm *)(&ucontext->uc_mcontext.mc_fpstate);
		xmm->sv_env.en_sw = 0;
		xmm->sv_env.en_mxcsr &= 0xffffffc0;
	}
}


#define UAP_STACK_POINTER(ucontext) (((ucontext_t *)ucontext)->uc_mcontext.mc_esp)
#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t *)ucontext)->uc_mcontext.mc_eip)

}
