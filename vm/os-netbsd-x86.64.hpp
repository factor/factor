#include <ucontext.h>

namespace factor
{

#define ucontext_stack_pointer(uap) \
	((void *)(((ucontext_t *)(uap))->uc_mcontext.__gregs[_REG_URSP]))

static inline unsigned int uap_fpu_status(void *uap) { return 0; }
static inline void uap_clear_fpu_status(void *uap) {  }

}
