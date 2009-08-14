namespace factor
{

#define FACTOR_CPU_STRING "x86.64"

register cell ds asm("r14");
register cell rs asm("r15");

#define VM_ASM_API VM_C_API

}
