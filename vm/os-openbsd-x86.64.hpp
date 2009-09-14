#include <amd64/signal.h>

namespace factor
{

inline static void *openbsd_stack_pointer(void *uap)
{
	struct sigcontext *sc = (struct sigcontext*) uap;
	return (void *)sc->sc_rsp;
}

#define ucontext_stack_pointer openbsd_stack_pointer
#define UAP_PROGRAM_COUNTER(uap) (((struct sigcontext*)(uap))->sc_rip)

static inline unsigned int uap_fpu_status(void *uap) { return 0; }
static inline void uap_clear_fpu_status(void *uap) {  }

}
