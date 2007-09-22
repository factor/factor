#define FACTOR_CPU_STRING "x86.32"

register CELL ds asm("esi");
register CELL rs asm("edi");

#define FASTCALL __attribute__ ((regparm (2)))

void set_callstack(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy);
