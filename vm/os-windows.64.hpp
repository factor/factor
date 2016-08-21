#include "atomic-cl-64.hpp"

namespace factor {

#define ESP Rsp
#define EIP Rip

#define MXCSR(ctx) (ctx)->MxCsr

// Must match the stack-frame-size constant in
// basis/bootstap/assembler/x86.64.windows.factor
static const unsigned JIT_FRAME_SIZE = 64;
}
