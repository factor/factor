#include <ucontext.h>

namespace factor
{

static inline unsigned int uap_fpu_status(void *uap) { return 0; }
static inline void uap_clear_fpu_status(void *uap) {}

#define UAP_STACK_POINTER(ucontext) (((ucontext_t *)ucontext)->uc_mcontext.__gregs[_REG_URSP])

}
