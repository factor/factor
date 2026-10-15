#include <signal.h>
#include <machine/npx.h>
namespace factor {
inline static unsigned int uap_fpu_status(void* uap) {
  auto fp = ((struct sigcontext*)uap)->sc_fpstate;
  return fp ? fp->sv_xmm.sv_env.en_sw | fp->sv_xmm.sv_env.en_mxcsr : 0;
}
inline static void uap_clear_fpu_status(void* uap) {
  auto fp = ((struct sigcontext*)uap)->sc_fpstate;
  if (fp) { fp->sv_xmm.sv_env.en_sw = 0; fp->sv_xmm.sv_env.en_mxcsr &= 0xffffffc0; }
}
#define UAP_STACK_POINTER(uap) (((struct sigcontext*)uap)->sc_esp)
#define UAP_PROGRAM_COUNTER(uap) (((struct sigcontext*)uap)->sc_eip)
}
