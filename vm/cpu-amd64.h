#define FACTOR_CPU_STRING "amd64"

register CELL ds asm("r14");
register CELL rs asm("r15");
register CELL cards_offset asm("r13");

INLINE void flush_icache(CELL start, CELL len) {}

void *native_stack_pointer(void);

typedef struct _F_STACK_FRAME {
	struct _F_STACK_FRAME *previous;
	CELL return_address;
} F_STACK_FRAME;

#define PREVIOUS_FRAME(frame) (frame->previous)
#define RETURN_ADDRESS(frame) (frame->return_address)
