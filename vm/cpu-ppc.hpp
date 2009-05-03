#define FACTOR_CPU_STRING "ppc"
#define F_FASTCALL

register CELL ds asm("r29");
register CELL rs asm("r30");

void c_to_factor(CELL quot);
void undefined(CELL word);
void set_callstack(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy);
void throw_impl(CELL quot, F_STACK_FRAME *rewind);
void lazy_jit_compile(CELL quot);
void flush_icache(CELL start, CELL len);
