#define FACTOR_CPU_STRING "ppc"

register CELL ds asm("r14");
register CELL rs asm("r15");
register CELL cards_offset asm("r16");

void flush_icache(CELL start, CELL len);
