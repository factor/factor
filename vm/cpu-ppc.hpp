namespace factor
{

#define FACTOR_CPU_STRING "ppc"
#define VM_ASM_API

register cell ds asm("r29");
register cell rs asm("r30");

void c_to_factor(cell quot);
void undefined(cell word);
void set_callstack(stack_frame *to, stack_frame *from, cell length, void *memcpy);
void throw_impl(cell quot, stack_frame *rewind);
void lazy_jit_compile(cell quot);
void flush_icache(cell start, cell len);

}
