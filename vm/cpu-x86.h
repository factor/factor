#define FACTOR_CPU_STRING "x86"

register CELL ds asm("esi");
register CELL rs asm("edi");
CELL cards_offset;

INLINE void flush_icache(CELL start, CELL len) {}

void *native_stack_pointer(void);

typedef struct _F_STACK_FRAME {
	struct _F_STACK_FRAME *previous;
	CELL *return_address;
} F_STACK_FRAME;
