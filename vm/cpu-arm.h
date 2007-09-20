#define FACTOR_CPU_STRING "arm"

register CELL ds asm("r5");
register CELL rs asm("r6");
register void **primitives asm("r7");

void *native_stack_pointer(void);

typedef CELL F_COMPILED_FRAME;

#define PREVIOUS_FRAME(frame) (frame + 1)
#define RETURN_ADDRESS(frame) (*(frame))

INLINE void execute(CELL word)
{
	untag_object(word)->xt(word);
}
