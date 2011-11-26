namespace factor
{

#define FACTOR_CPU_STRING "x86.32"

/* Must match the leaf-stack-frame-size stack-frame-size constants in
cpu/x86/32/bootstrap.factor */
static const unsigned LEAF_FRAME_SIZE = 16;
static const unsigned JIT_FRAME_SIZE = 32;

}
