namespace factor
{

#define FACTOR_CPU_STRING "x86.32"

register cell ds asm("esi");
register cell rs asm("edi");

#define VM_ASM_API extern "C" __attribute__ ((regparm (2)))

}
