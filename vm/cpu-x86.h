#define FACTOR_CPU_STRING "ppc"

register CELL ds asm("esi");
register CELL rs asm("edi");
CELL cards_offset;

INLINE void flush_icache(void *start, int len) {}
