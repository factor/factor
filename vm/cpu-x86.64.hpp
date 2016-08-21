namespace factor {

#define FACTOR_CPU_STRING "x86.64"

// Must match the calculation in word jit-signal-handler-prolog in
// basis/bootstrap/assembler/x86.factor
static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 192;

}
