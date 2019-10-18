#include <ucontext.h>

namespace factor
{

static inline unsigned int uap_fpu_status(void *uap) { return 0; }
static inline void uap_clear_fpu_status(void *uap) {}

#define UAP_STACK_POINTER(ucontext) (_UC_MACHINE_SP((ucontext_t *)ucontext))

}
