#include <ucontext.h>

namespace factor
{

#define UAP_PROGRAM_COUNTER(uap)    _UC_MACHINE_PC((ucontext_t *)uap)

}
