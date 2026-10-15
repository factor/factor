#include <signal.h>
#include <machine/fpu.h>
namespace factor {
inline static unsigned int uap_fpu_status(void* uap) {
  auto fp = ((struct sigcontext*)uap)->sc_fpstate;
  return fp ? fp->fx_fsw | fp->fx_mxcsr : 0;
}
inline static void uap_clear_fpu_status(void* uap) {
  auto fp = ((struct sigcontext*)uap)->sc_fpstate;
  if (fp) { fp->fx_fsw = 0; fp->fx_mxcsr &= 0xffffffc0; }
}
#define UAP_STACK_POINTER(uap) (((struct sigcontext*)uap)->sc_rsp)
#define UAP_PROGRAM_COUNTER(uap) (((struct sigcontext*)uap)->sc_rip)
static const unsigned JIT_FRAME_SIZE = 32;
}
