namespace factor {

#define FACTOR_CPU_STRING "x86.32"

/* Must match the leaf-stack-frame-size, signal-handler-stack-frame-size,
and stack-frame-size constants in bootstrap/assembler/x86.32.factor */
static const unsigned LEAF_FRAME_SIZE = 16;
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 48;
static const unsigned JIT_FRAME_SIZE = 32;

}
