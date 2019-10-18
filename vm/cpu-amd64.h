#define FACTOR_CPU_STRING "amd64"

register CELL ds asm("r14");
register CELL rs asm("r15");
register CELL cards_offset asm("r13");

INLINE void flush_icache(void *start, int len) {}
