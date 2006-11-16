#define FACTOR_CPU_STRING "x86"

register CELL ds asm("esi");
register CELL rs asm("edi");
CELL cards_offset;

INLINE void flush_icache(CELL start, CELL len) {}

INLINE void *native_stack_pointer(void)
{
	void *ptr;
	asm("mov %%ebp, %0" : "=r" (ptr));
	return ptr;
}

typedef struct _F_STACK_FRAME {
	struct _F_STACK_FRAME *previous;
	CELL *return_address;
} F_STACK_FRAME;
