#define FACTOR_CPU_STRING "arm"

register CELL ds asm("r5");
register CELL rs asm("r6");

#define F_FASTCALL

void c_to_factor(CELL quot);
void dosym(CELL word);
void docol_profiling(CELL word);
void docol(CELL word);
void undefined(CELL word);
void set_callstack(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy);
void throw_impl(CELL quot, F_STACK_FRAME *rewind);
void lazy_jit_compile(CELL quot);
void flush_icache(CELL start, CELL len);

#define FRAME_RETURN_ADDRESS(frame) *((XT *)(frame_successor(frame) + 1) + 1)
