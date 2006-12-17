#define FACTOR_CPU_STRING "ppc"

register CELL ds asm("r14");
register CELL rs asm("r15");
register CELL cards_offset asm("r16");

void flush_icache(CELL start, CELL len);

void *native_stack_pointer(void);

#define PREVIOUS_FRAME(frame) (frame->previous)
#define RETURN_ADDRESS(frame) (frame->return_address)
