namespace factor
{

#define FACTOR_CPU_STRING "arm"

register cell ds asm("r5");
register cell rs asm("r6");

#define FRAME_RETURN_ADDRESS(frame) *(XT *)(frame_successor(frame) + 1)

void c_to_factor(cell quot);
void set_callstack(stack_frame *to, stack_frame *from, cell length, void *memcpy);
void throw_impl(cell quot, stack_frame *rewind);
void lazy_jit_compile(cell quot);

}
