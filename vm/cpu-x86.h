#define FACTOR_CPU_STRING "x86"

register CELL ds asm("esi");
register CELL rs asm("edi");
CELL cards_offset;

INLINE void flush_icache(CELL start, CELL len) {}
