#include "atomic-cl-64.hpp"

namespace factor {

#define ESP Rsp
#define EIP Rip

#define MXCSR(ctx) (ctx)->MxCsr

/* Must match the signal-handler-stack-frame-size and stack-frame-size
   constants in basis/bootstap/assembler/x86.64.windows.factor */
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 192;
static const unsigned JIT_FRAME_SIZE = 64;
}
