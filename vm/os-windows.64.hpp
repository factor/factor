#include "atomic-cl-64.hpp"

namespace factor
{

#define ESP Rsp
#define EIP Rip

#define MXCSR(ctx) (ctx)->MxCsr

/* Must match the leaf-stack-frame-size, signal-handler-stack-frame-size,
and stack-frame-size constants in basis/cpu/x86/64/windows/bootstrap.factor */

static const unsigned LEAF_FRAME_SIZE = 32;
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 192;
static const unsigned JIT_FRAME_SIZE = 64;
}
