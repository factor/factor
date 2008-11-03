#define FACTOR_CPU_STRING "x86.32"

register CELL ds asm("esi");
register CELL rs asm("edi");

#define F_FASTCALL __attribute__ ((regparm (2)))

DLLEXPORT bool check_sse2(void);
