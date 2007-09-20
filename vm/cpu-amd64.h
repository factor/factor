#define FACTOR_CPU_STRING "x86.64"

register CELL ds asm("r14");
register CELL rs asm("r15");
void **primitives;

INLINE void flush_icache(CELL start, CELL len) {}

void *native_stack_pointer(void);

typedef CELL F_COMPILED_FRAME;

#define PREVIOUS_FRAME(frame) (frame + 1)
#define RETURN_ADDRESS(frame) (*(frame))

INLINE void execute(CELL word)
{
	F_WORD *untagged = untag_object(word);
	untagged->xt(word);
}
