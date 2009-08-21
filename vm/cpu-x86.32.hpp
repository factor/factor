namespace factor
{

#define FACTOR_CPU_STRING "x86.32"

register cell ds asm("esi");
register cell rs asm("edi");

#define VM_ASM_API VM_C_API __attribute__ ((regparm (2)))
#undef VM_PTR
#define VM_PTR myvm
#undef ASSERTVM
#define ASSERTVM() assert(vm==myvm)
}
