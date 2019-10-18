#include <i386/signal.h>

namespace factor
{

static inline unsigned int uap_fpu_status(void *uap) { return 0; }
static inline void uap_clear_fpu_status(void *uap) {}

#define UAP_STACK_POINTER(ucontext) (((struct sigcontext *)ucontext)->sc_esp)
#define UAP_PROGRAM_COUNTER(ucontext) (((struct sigcontext *)ucontext)->sc_eip)

}
