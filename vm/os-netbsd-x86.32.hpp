#include <ucontext.h>

namespace factor
{

#define ucontext_stack_pointer(uap) ((void *)_UC_MACHINE_SP((ucontext_t *)uap))

static inline unsigned int uap_fpu_status(void *uap) { return 0; }
static inline void uap_clear_fpu_status(void *uap) {  }

}
