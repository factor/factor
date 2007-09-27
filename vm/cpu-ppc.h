#define FACTOR_CPU_STRING "ppc"
#define F_FASTCALL

register CELL ds asm("r14");
register CELL rs asm("r15");

void c_to_factor(CELL quot);
void dosym(CELL word);
void docol_profiling(CELL word);
void docol(CELL word);
void undefined(CELL word);
void set_callstack(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy);
void throw_impl(CELL quot, F_STACK_FRAME *rewind);
void lazy_jit_compile(CELL quot);
void flush_icache(CELL start, CELL len);

#define FRAME_SUCCESSOR(frame) (frame)->previous
