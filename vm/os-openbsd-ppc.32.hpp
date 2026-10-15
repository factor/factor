#include <sys/types.h>
#include <signal.h>
#include <machine/frame.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

namespace factor {

#define UAP_LINK_REGISTER(ucontext) (((struct sigcontext*)ucontext)->sc_frame.lr)

#define UAP_STACK_POINTER(uap) (((struct sigcontext*)uap)->sc_frame.fixreg[1])
#define UAP_PROGRAM_COUNTER(uap) (((struct sigcontext*)uap)->sc_frame.srr0)

// macppc sigcode saves f0-f13 and FPSCR below the public signal frame,
// then restores FPSCR after the handler. Clearing only the live register
// is undone by that restoration.
static_assert(sizeof(struct fpsig) == 120, "macppc signal FP layout");
static_assert(offsetof(struct sigframe, sf_sc) == 8, "macppc signal context");

inline static struct fpsig* uap_fp_state(void* uap) {
  const size_t trampoline_frame = (16 + sizeof(struct fpsig) + 15) & ~size_t(15);
  return (struct fpsig*)((char*)uap - offsetof(struct sigframe, sf_sc)
                         - trampoline_frame + 8);
}

inline static unsigned int uap_fpu_status(void* uap) {
  uint64_t status;
  memcpy(&status, &uap_fp_state(uap)->fpscr, sizeof(status));
  return (unsigned int)status;
}

inline static void uap_clear_fpu_status(void* uap) {
  uint64_t status;
  memcpy(&status, &uap_fp_state(uap)->fpscr, sizeof(status));
  status &= UINT64_C(0xffffffff0007f8ff);
  memcpy(&uap_fp_state(uap)->fpscr, &status, sizeof(status));
}

}
