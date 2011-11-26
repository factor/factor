#include "atomic-cl-64.hpp"

namespace factor
{

#define ESP Rsp
#define EIP Rip

#define MXCSR(ctx) (ctx)->MxCsr

/* Must match the leaf-stack-frame-size and stack-frame-size constants
in basis/cpu/x86/64/windows/bootstrap.factor */

static const unsigned LEAF_FRAME_SIZE = 32;
static const unsigned JIT_FRAME_SIZE = 64;
}
