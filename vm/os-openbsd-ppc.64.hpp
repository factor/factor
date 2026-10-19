#include <signal.h>
#include <stdint.h>

namespace factor {

// powerpc64 exposes the saved GPRs and FPSCR directly in sigcontext.
#define UAP_LINK_REGISTER(uap) (((struct sigcontext*)(uap))->sc_lr)
#define UAP_STACK_POINTER(uap) (((struct sigcontext*)(uap))->sc_reg[1])
#define UAP_PROGRAM_COUNTER(uap) (((struct sigcontext*)(uap))->sc_pc)
#define UAP_GLOBAL_ENTRY_REGISTER(uap) (((struct sigcontext*)(uap))->sc_reg[12])
#define UAP_TOC_REGISTER(uap) (((struct sigcontext*)(uap))->sc_reg[2])

inline static unsigned int uap_fpu_status(void* uap) {
  return (unsigned int)((struct sigcontext*)uap)->sc_fpscr;
}

inline static void uap_clear_fpu_status(void* uap) {
  ((struct sigcontext*)uap)->sc_fpscr &= UINT64_C(0xffffffff0007f8ff);
}

}
