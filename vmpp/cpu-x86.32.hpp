#define FACTOR_CPU_STRING "x86.32"

register CELL ds asm("esi");
register CELL rs asm("edi");

#define F_FASTCALL extern "C" __attribute__ ((regparm (2)))
