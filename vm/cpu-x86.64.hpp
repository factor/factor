namespace factor
{

#define FACTOR_CPU_STRING "x86.64"

register CELL ds asm("r14");
register CELL rs asm("r15");

#define VM_ASM_API extern "C"

}
